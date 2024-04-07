// SupabaseのサーバークライアントとCookieオプションの型をインポートします。
// Import the server client for Supabase and CookieOptions type.
import { createServerClient, type CookieOptions } from "@supabase/ssr";
// Next.jsのレスポンスとリクエストの型をインポートします。
// Import types for Next.js response and request.
import { NextResponse, type NextRequest } from "next/server";

// セッション更新の非同期関数を定義します。
// Define an asynchronous function for session update.
export async function updateSession(request: NextRequest) {
  // 次のレスポンスを初期化します。
  // Initialize the next response.
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  });

  // Supabaseのサーバークライアントを作成します。
  // Create the server client for Supabase.
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        // Cookieを取得します。
        // Get cookies.
        get(name: string) {
          return request.cookies.get(name)?.value;
        },
        // Cookieを設定します。
        // Set cookies.
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
        // Remove cookies.
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
  // Get user information.
  await supabase.auth.getUser();

  return response;
}
