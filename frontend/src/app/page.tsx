import AuthButton from "@/components/AuthButton";

export default async function Index() {
  return (
    <div>
      <nav>
        Supabase SSR 認証でのログイン
        <AuthButton />
      </nav>
    </div>
  );
}
