// SupabaseのサーバークライアントとCookieオプションの型をインポートします。
import { createServerClient, type CookieOptions } from "@supabase/ssr";
// Next.jsのレスポンスとリクエストの型をインポートします。
import { NextResponse, type NextRequest } from "next/server";

// セッション更新の非同期関数を定義します。
export async function updateSession(request: NextRequest) {
  // 次のレスポンスを初期化します。
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  });

  // Supabaseのサーバークライアントを作成します。
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        // Cookieを取得します。
        get(name: string) {
          return request.cookies.get(name)?.value;
        },
        // Cookieを設定します。
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({
            name,
            value,
            ...options,
          });
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          });
          response.cookies.set({
            name,
            value,
            ...options,
          });
        },
        // Cookieを削除します。
        remove(name: string, options: CookieOptions) {
          request.cookies.set({
            name,
            value: "",
            ...options,
          });
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          });
          response.cookies.set({
            name,
            value: "",
            ...options,
          });
        },
      },
    }
  );

  // ユーザー情報を取得します。
  await supabase.auth.getUser();

  return response;
}
