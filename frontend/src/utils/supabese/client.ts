// 以前はSupabaseのクライアントを直接インポートしていましたが、
// import { createClient } from "@supabase/supabase-js";
// Supabase SSR用のクライアントに変更しました。
// これにより、ブラウザサイドでの動作を最適化し、サーバーサイドレンダリング時の認証処理を強化します。
import { createBrowserClient } from "@supabase/ssr";

export function createClient() {
  // createBrowserClientを使用してSupabaseのクライアントを作成し、
  // 環境変数からURLとANON KEYを取得します。
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
