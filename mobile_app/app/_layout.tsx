import Chatbot from "@/components/chatbot";
import Header from "@/components/layout/Header";
import { AuthProvider } from "@/context/AuthContext";
import { CartProvider } from "@/context/CartContext";
import { Slot, useSegments } from "expo-router";
import { View } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";

export default function RootLayout() {
  const segments = useSegments();
  const isAdmin = segments[0] === 'admin';

  return (
    <SafeAreaProvider>
      <AuthProvider>
        <CartProvider>
          <View style={{ flex: 1 }}>
            {!isAdmin && <Header />}
            <View style={{ flex: 1 }}>
              <Slot />
            </View>
          </View>
          <Chatbot />
        </CartProvider>
      </AuthProvider>
    </SafeAreaProvider>
  );
}
