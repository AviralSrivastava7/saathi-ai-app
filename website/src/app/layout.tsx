import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  metadataBase: new URL("https://saathiai.tech"),
  title: "Saathi AI — Your Private, Offline Mental Health Companion",
  description:
    "Saathi AI is a 100% offline, privacy-first mental wellness companion powered by on-device Gemma AI. No data leaves your phone. Free forever. Speaks Hinglish.",
  keywords: [
    "Saathi AI",
    "Mental health app India",
    "Offline AI companion",
    "Privacy first mental health",
    "Gemma 2B on-device AI",
    "Hinglish mental health",
    "Free meditation app",
    "AI wellness companion",
    "Flutter mental health app",
  ].join(", "),
  authors: [{ name: "Aviral Srivastava" }],
  creator: "Aviral Srivastava",
  publisher: "Saathi AI",
  openGraph: {
    title: "Saathi AI — Your Private, Offline Mental Health Companion",
    description:
      "100% offline. Zero data collection. Powered by on-device Gemma AI. Free forever.",
    url: "https://saathiai.tech",
    siteName: "Saathi AI",
    locale: "en_IN",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Saathi AI — Privacy-First Mental Wellness",
    description:
      "On-device AI companion for mental health. No servers, no cloud, no data sharing.",
  },
  alternates: {
    canonical: "https://saathiai.tech",
  },
};

const jsonLd = [
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: "Saathi AI",
    url: "https://saathiai.tech",
  },
  {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: "Saathi AI",
    operatingSystem: "Android, iOS, Windows, Mac, Linux, Web",
    applicationCategory: "HealthApplication",
    description:
      "Saathi AI is a 100% offline, privacy-first mental wellness companion powered by on-device AI.",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "INR",
    },
    author: {
      "@type": "Person",
      name: "Aviral Srivastava",
    },
  },
];

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin=""
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="antialiased" suppressHydrationWarning>
        <Navbar />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        {children}
        <Footer />
      </body>
    </html>
  );
}
