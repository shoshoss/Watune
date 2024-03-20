// src/components/RegistrationForm.tsx
import React from 'react';
import { useForm } from 'react-hook-form';
import { useDispatch } from 'react-redux';
import { registerUser } from '../features/auth/authSlice';
import type { AppDispatch } from '../app/store'; // カスタムディスパッチ関数の型をインポート

// フォームの入力値の型を定義
interface IFormInput {
  email: string;
  password: string;
}

export const RegistrationForm = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { register, handleSubmit, formState: { errors } } = useForm<IFormInput>();

  const onSubmit = (data: IFormInput) => {
    dispatch(registerUser(data));
  };

  return (
    <div className="form-container">
      <button className="oauth-button">Googleで登録</button>
      <div className="separator">または</div>
      <form onSubmit={handleSubmit(onSubmit)}>
        <div className="form-group">
          <label htmlFor="email">メールアドレス</label>
          <input id="email" {...register("email", { required: true, pattern: /^\S+@\S+$/i })} />
          {errors.email && <span role="alert">無効なメールアドレスです</span>}
        </div>
        <div className="form-group">
          <label htmlFor="password">パスワード</label>
          <input id="password" type="password" {...register("password", { required: true, minLength: 6 })} />
          {errors.password && <span role="alert">パスワードは8文字以上である必要があります</span>}
        </div>
        <button type="submit" className="form-group button">新規登録の手続きのメールを送信</button>
      </form>
    </div>
  );
};
