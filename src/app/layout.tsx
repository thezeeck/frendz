import type { Metadata } from "next";
import { DM_Sans } from "next/font/google";
import "./globals.css";
import Header from "@/components/Header";
import { Suspense } from "react";
import Loader from "@/components/Loader";
import Sidebar from "@/components/Sidebar";

const dmSans = DM_Sans({
  subsets: ["latin"],
  variable: "--font-dm-sans",
  display: "swap",
  weight: ["400", "500", "700"],
});

export const metadata: Metadata = {
  title: "Frendz",
  description: "Welcome to Frendz, your go-to platform for connecting with friends and sharing experiences.",
  icons: {
    icon: "favicon/favicon.ico",
    shortcut: "favicon/favicon.ico",
    apple: "favicon/apple-icon.png",
    other: {
      rel: "manifest",
      url: "favicon/manifest.json",
    }
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${dmSans.variable}`}>
        <div className="main">
          <Header />
          <Suspense fallback={<Loader />}>
            <Sidebar />
          </Suspense>
          {children}
        </div>
      </body>
    </html>
  );
}
