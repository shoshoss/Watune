import React from 'react';
import { useForm } from 'react-hook-form';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
// configureStoreをインポート
import { configureStore } from '@reduxjs/toolkit';
import App from '../App';

interface Action {
  type: string;
  payload?: any; // ペイロードの型が何であるかに応じて、anyの部分を適切な型に変更する
}

// testReducerはそのままでOK
const testReducer = (state = {}, action: Action) => {
  switch (action.type) {
    default:
      return state;
  }
};

// createStoreの代わりにconfigureStoreを使用してテスト用のストアを作成
const testStore = configureStore({
  reducer: testReducer,
});

test('renders learn react link', () => {
  render(
    <Provider store={testStore}>
      <App />
    </Provider>
  );
  const linkElement = screen.getByText(/Googleで登録/i);
  expect(linkElement).toBeInTheDocument();
});
