import { createClient } from "@supabase/supabase-js";
import { Auth } from "@supabase/auth-ui-react";
import { ThemeSupa } from "@supabase/auth-ui-shared";

export default function Google() {
  const supabase = createClient("Project URL", "Project API anon key");

  return (
    <>
      <div>
        <main>
          <div>
            <Auth
              supabaseClient={supabase}
              appearance={{ theme: ThemeSupa }}
              providers={["google"]}
            />
          </div>
        </main>
      </div>
    </>
  );
}
