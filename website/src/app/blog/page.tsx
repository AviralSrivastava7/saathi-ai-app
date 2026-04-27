import type { Metadata } from "next";
import BlogListClient from "./BlogListClient";

export const metadata: Metadata = {
    title: "Blog — Saathi AI | Mental Health Tips & Wellness Articles",
    description:
        "Mental health, meditation, self-care aur AI wellness ke baare mein helpful Hinglish articles padhein. Saathi AI blog — aapka wellness knowledge companion.",
    openGraph: {
        title: "Blog — Saathi AI",
        description: "Mental health aur wellness ke baare mein Hinglish mein articles padhein.",
        url: "https://saathiai.tech/blog",
    },
};

export default function BlogPage() {
    return <BlogListClient />;
}
