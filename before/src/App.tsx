// src/App.tsx
import React from 'react';
import './App.css';
// 1. RegistrationFormコンポーネントをインポート
import { RegistrationForm } from './components/RegistrationForm';

function App() {
  return (
    <div className="App">
      {/* アプリケーションのメインコンテンツ */}
      <header className="App-header">
        {/* 他のコンテンツがあればここに記述 */}
        
        {/* 2. RegistrationFormコンポーネントを配置 */}
        <RegistrationForm />
        
        {/* 他のコンテンツがあればここに続けて記述 */}
      </header>
    </div>
  );
}

export default App;
