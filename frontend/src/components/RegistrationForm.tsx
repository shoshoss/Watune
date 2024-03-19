// src/components/RegistrationForm.tsx
import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { registerUser } from '../features/auth/authSlice';
import type { AppDispatch } from '../app/store'; // カスタムディスパッチ関数の型をインポート

export const RegistrationForm = () => {
  // ステートフックでフォームの入力値を管理
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const dispatch = useDispatch<AppDispatch>(); // カスタムのディスパッチ関数の型を使用

  // フォームの送信処理
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    dispatch(registerUser({ email, password }));
  };

  // JSXでフォームを返します
  return (
    <div className="form-container">
      <button className="oauth-button">Googleで登録</button>
      <div className="separator">または</div>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="email">メールアドレス</label>
          <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
        </div>
        <div className="form-group">
          <label htmlFor="password">パスワード</label>
          <input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </div>
        <button type="submit" className="form-group button">新規登録の手続きをメールを送信</button>
      </form>
    </div>
  );
};
