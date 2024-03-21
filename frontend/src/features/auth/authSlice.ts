import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';

// ユーザー情報の型を定義
interface User {
  // 必要に応じてユーザーの属性を追加
}

// 認証状態の型を定義
interface AuthState {
  user: User | null;
  status: 'idle' | 'loading' | 'failed';
  error: string | null;
}

// 初期状態を設定
const initialState: AuthState = {
  user: null,
  status: 'idle',
  error: null,
};

// ユーザー登録のための非同期アクションを作成
export const registerUser = createAsyncThunk<User, { email: string; password: string }, { rejectValue: string }>(
  'auth/registerUser',
  async (userData, { rejectWithValue }) => {
    try {
      const response = await fetch('/api/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(userData),
      });

      if (!response.ok) {
        // サーバーエラーの場合は例外を投げる
        throw new Error('サーバーからのレスポンスが失敗しました');
      }

      // レスポンスからユーザー情報を取得
      const data = await response.json();
      return data;
    } catch (error: unknown) {
      // エラーが発生した場合はエラーメッセージを返す
      if (error instanceof Error) {
        return rejectWithValue(error.message);
      }
      // 不明なエラーの場合は汎用的なメッセージを返す
      return rejectWithValue('予期せぬエラーが発生しました');
    }
  }
);

// 認証関連のスライスを作成
export const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    // ユーザー情報をセットするアクション
    setUser: (state, action: PayloadAction<User | null>) => {
      state.user = action.payload;
    },
    // ユーザー情報をクリアするアクション
    clearUser: (state) => {
      state.user = null;
    },
  },
  extraReducers: (builder) => {
    // ユーザー登録成功時の状態更新処理
    builder.addCase(registerUser.fulfilled, (state, action: PayloadAction<User>) => {
      state.user = action.payload;
      state.status = 'idle';
      state.error = null;
    })
    // ユーザー登録失敗時の状態更新処理
    .addCase(registerUser.rejected, (state, action) => {
      state.status = 'failed';
      // エラーがrejectWithValueからのものであればそれを、そうでなければ汎用的なメッセージを設定
      state.error = action.payload ?? '登録に失敗しました';
    });
  },
});

// アクションクリエーターをエクスポート
export const { setUser, clearUser } = authSlice.actions;

// スライスのリデューサーをエクスポート
export default authSlice.reducer;
