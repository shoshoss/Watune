// SupabaseのサーバーサイドクライアントとCookie処理ユーティリティをインポート
import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";

// Supabaseクライアントを作成し設定する関数
export function createClient() {
  const cookieStore = cookies(); // クッキーストアの取得

  // Supabaseクライアントを作成。環境変数からURLとANON KEYを取得し、クッキー設定を追加
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
          }
        },
        remove(name: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value: "", ...options }); // クッキーを削除
          } catch (error) {
            // サーバーコンポーネントから`delete`メソッドが呼ばれた場合、ユーザーセッションをリフレッシュするミドルウェアがあれば無視可能
          }
        },
      },
    }
  );
}
