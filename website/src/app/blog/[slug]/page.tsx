import type { Metadata } from "next";
import { getBlogPostBySlug, getAllSlugs } from "@/utils/blogData";
import BlogPostClient from "./BlogPostClient";
import { notFound } from "next/navigation";

interface Props {
    params: Promise<{ slug: string }>;
}

export async function generateStaticParams() {
    return getAllSlugs().map((slug) => ({ slug }));
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
    const { slug } = await params;
    const post = getBlogPostBySlug(slug);
    if (!post) return { title: "Post Not Found — Saathi AI" };

    return {
        title: `${post.title} — Saathi AI Blog`,
        description: post.excerpt,
        openGraph: {
            title: post.title,
            description: post.excerpt,
            url: `https://saathiai.tech/blog/${post.slug}`,
            type: "article",
            publishedTime: post.date,
            authors: [post.author],
        },
    };
}

export default async function BlogPostPage({ params }: Props) {
    const { slug } = await params;
    const post = getBlogPostBySlug(slug);
    if (!post) notFound();

    return <BlogPostClient post={post} />;
}
