// Supabaseクライアントを初期化し、環境変数からSupabaseのURLとANON KEYを取得
// Initialize the Supabase client and retrieve Supabase URL and ANON KEY from environment variables
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  // SupabaseのURLとANON KEYを環境変数から取得して、クライアントを作成
  // Retrieve the Supabase URL and ANON KEY from environment variables to create the client
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
