import { configureStore } from '@reduxjs/toolkit';
import authReducer from '../features/auth/authSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
  },
});

// storeのdispatch関数の型をエクスポートします
export type AppDispatch = typeof store.dispatch;
