-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create profiles table
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Create memories table
CREATE TABLE public.memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,                  -- Encrypted on-device in zero-knowledge production
    description TEXT,                     -- Encrypted on-device in zero-knowledge production
    file_path TEXT,                       -- Supabase Storage reference
    file_url TEXT,                        -- Signed/public URL
    file_size BIGINT,
    mime_type TEXT,
    sha256_hash TEXT NOT NULL,            -- Tampering detection
    category TEXT NOT NULL CHECK (category IN ('Education', 'Career', 'Health', 'Finance', 'Personal', 'Important Documents', 'Saved Links', 'AI Generated', 'Dump')),
    priority_score INTEGER DEFAULT 50 CHECK (priority_score >= 0 AND priority_score <= 100),
    tags TEXT[] DEFAULT '{}' NOT NULL,
    ocr_text TEXT,                        -- Encrypted on-device in zero-knowledge production
    ai_summary TEXT,                      -- Encrypted on-device in zero-knowledge production
    is_processed BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS for memories
ALTER TABLE public.memories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own memories"
    ON public.memories FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create reminders table
CREATE TABLE public.reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    memory_id UUID REFERENCES public.memories(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS for reminders
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own reminders"
    ON public.reminders FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create memory_relationships table for Memory Graph
CREATE TABLE public.memory_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    source_id UUID REFERENCES public.memories(id) ON DELETE CASCADE NOT NULL,
    target_id UUID REFERENCES public.memories(id) ON DELETE CASCADE NOT NULL,
    relationship_type TEXT NOT NULL, -- e.g., 'prerequisite', 'reference', 'receipt', 'resume_to_job'
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_relationship UNIQUE (source_id, target_id)
);

-- Enable RLS for memory_relationships
ALTER TABLE public.memory_relationships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own relationships"
    ON public.memory_relationships FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create trusted_devices table
CREATE TABLE public.trusted_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    device_fingerprint TEXT NOT NULL,
    device_name TEXT NOT NULL,
    last_login_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_device UNIQUE (user_id, device_fingerprint)
);

-- Enable RLS for trusted_devices
ALTER TABLE public.trusted_devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own trusted devices"
    ON public.trusted_devices FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Performance Indexes
CREATE INDEX idx_memories_user_category ON public.memories (user_id, category);
CREATE INDEX idx_memories_tags ON public.memories USING gin (tags);
CREATE INDEX idx_relationships_source ON public.memory_relationships (source_id);
CREATE INDEX idx_relationships_target ON public.memory_relationships (target_id);

-- Trigram Indexes for search optimizations (on columns if unencrypted)
CREATE INDEX idx_memories_title_trgm ON public.memories USING gin (title gin_trgm_ops);
CREATE INDEX idx_memories_ocr_trgm ON public.memories USING gin (ocr_text gin_trgm_ops);

-- Profile auto-generation on user signup trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', new.email),
        new.raw_user_meta_data->>'avatar_url'
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
