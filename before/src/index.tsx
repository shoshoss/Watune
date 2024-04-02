import React from 'react';
import ReactDOM from 'react-dom/client'; // React 18の新しいインポート方法
import { Provider } from 'react-redux';
import { store } from './app/store';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement); // React 18の新しいルートAPI
root.render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>
);
