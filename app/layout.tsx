import type { Metadata, Viewport } from "next";
import "./globals.css";

export const viewport: Viewport = {width: "device-width", initialScale: 1, viewportFit: "cover", colorScheme: "light"};

export const metadata: Metadata = {
  title: "IBAGY · Departamento Pessoal",
  description: "Lançamentos mensais, histórico de colaboradores e exportações para contabilidade.",
  other: {
    "codex-preview": "development",
  },
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="pt-BR">
      <body className="antialiased">{children}</body>
    </html>
  );
}
