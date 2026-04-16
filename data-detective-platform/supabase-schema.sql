-- ═══════════════════════════════════════════════════════════
-- DATA DETECTIVE — Supabase Database Schema
-- Chạy SQL này trong Supabase SQL Editor (https://supabase.com/dashboard)
-- ═══════════════════════════════════════════════════════════

-- 1. Bảng PLAYERS — lưu thông tin người chơi
CREATE TABLE players (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  mssv TEXT NOT NULL,
  character TEXT NOT NULL CHECK (character IN ('minh', 'linh', 'duc', 'huong')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Index cho tìm kiếm nhanh theo MSSV
CREATE INDEX idx_players_mssv ON players(mssv);

-- 2. Bảng GAME_RESULTS — lưu kết quả mỗi lần chơi
CREATE TABLE game_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  mssv TEXT NOT NULL,
  character TEXT NOT NULL,
  total_score INTEGER NOT NULL DEFAULT 0,
  phase1_score INTEGER DEFAULT 0,
  phase2_score INTEGER DEFAULT 0,
  phase3_score INTEGER DEFAULT 0,
  phase4_score INTEGER DEFAULT 0,
  rank TEXT DEFAULT 'Bronze',
  achievements TEXT[] DEFAULT '{}',
  phase4_answer JSONB DEFAULT '{}',
  duration_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Index cho leaderboard (sắp xếp theo điểm)
CREATE INDEX idx_results_score ON game_results(total_score DESC);
CREATE INDEX idx_results_created ON game_results(created_at DESC);

-- 3. View LEADERBOARD — top scores, mỗi sinh viên chỉ lấy điểm cao nhất
CREATE OR REPLACE VIEW leaderboard AS
SELECT DISTINCT ON (mssv)
  id, name, mssv, character, total_score, rank,
  phase1_score, phase2_score, phase3_score, phase4_score,
  achievements, created_at
FROM game_results
ORDER BY mssv, total_score DESC, created_at DESC;

-- 4. View LEADERBOARD_RANKED — có xếp hạng thứ tự
CREATE OR REPLACE VIEW leaderboard_ranked AS
SELECT *,
  ROW_NUMBER() OVER (ORDER BY total_score DESC, created_at ASC) AS position
FROM leaderboard
ORDER BY total_score DESC;

-- ═══════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════

-- Bật RLS
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_results ENABLE ROW LEVEL SECURITY;

-- Cho phép anonymous users INSERT (sinh viên nộp bài)
CREATE POLICY "Anyone can insert players"
  ON players FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can read players"
  ON players FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert results"
  ON game_results FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can read results"
  ON game_results FOR SELECT
  USING (true);

-- Chỉ authenticated users (giảng viên) mới được DELETE/UPDATE
CREATE POLICY "Auth users can update results"
  ON game_results FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Auth users can delete results"
  ON game_results FOR DELETE
  USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════
-- REALTIME — Bật realtime cho bảng game_results
-- ═══════════════════════════════════════════════════════════
ALTER PUBLICATION supabase_realtime ADD TABLE game_results;
