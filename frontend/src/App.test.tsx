import React from 'react';
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import App from './App';

interface Action {
  type: string;
  payload?: any; // ペイロードの型が何であるかに応じて、anyの部分を適切な型に変更する
}

const testReducer = (state = {}, action: Action) => {
  switch (action.type) {
    // アクションのタイプに応じた処理をここに記述
    default:
      return state;
  }
};

// テスト用のReduxストアを作成
const testStore = createStore(testReducer);

test('renders learn react link', () => {
  // <Provider>で<App />をラップして、テスト用のストアを提供
  render(
    <Provider store={testStore}>
      <App />
    </Provider>
  );
  // ここで、Appコンポーネント内に存在する特定のテキストを検索
  // このテキストがコンポーネントの期待される振る舞いとして正しくレンダリングされているかテストします
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
});
