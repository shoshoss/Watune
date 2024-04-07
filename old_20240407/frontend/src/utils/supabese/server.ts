// SupabaseのサーバーサイドクライアントとCookie処理ユーティリティをインポート
// Import the server-side client for Supabase and cookie handling utility
import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";

// Supabaseクライアントを作成し設定する関数
// Function to create and configure the Supabase client
export function createClient() {
  const cookieStore = cookies(); // クッキーストアの取得

  // Supabaseクライアントを作成。環境変数からURLとANON KEYを取得し、クッキー設定を追加
  // Create the Supabase client. Retrieve URL and ANON KEY from environment variables and add cookie settings
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value; // クッキーから値を取得
        },
        set(name: string, value: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value, ...options }); // クッキーを設定
          } catch (error) {
            // サーバーコンポーネントから`set`メソッドが呼ばれた場合、ユーザーセッションをリフレッシュするミドルウェアがあれば無視可能
            // Ignore if called from server component and there's middleware to refresh user session when `set` method is called
          }
        },
        remove(name: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value: "", ...options }); // クッキーを削除
          } catch (error) {
            // サーバーコンポーネントから`delete`メソッドが呼ばれた場合、ユーザーセッションをリフレッシュするミドルウェアがあれば無視可能
            // Ignore if called from server component and there's middleware to refresh user session when `delete` method is called
          }
        },
      },
    }
  );
}
