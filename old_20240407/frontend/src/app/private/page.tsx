// next/navigationからredirect関数をインポートします
import { redirect } from "next/navigation";

// supabase/serverユーティリティからSupabaseクライアントを作成する関数をインポートします
import { createClient } from "../../utils/supabese/server";

// 非公開ページのコンポーネントです。認証済みユーザーのみがアクセス可能です。
export default async function PrivatePage() {
  // Supabaseクライアントを初期化します
  const supabase = createClient();

  // ユーザー情報を取得します。エラーがあるか、ユーザー情報がなければルートにリダイレクトします
  const { data, error } = await supabase.auth.getUser();
  if (error || !data?.user) {
    redirect("/"); // ユーザーが認証されていなければホームページにリダイレクト
  }

  // ユーザーが認証されている場合、ユーザーのメールアドレスで挨拶を表示します
  return <p>Hello {data.user.email}</p>;
}
