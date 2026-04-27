"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import type { BlogPost } from "@/utils/blogData";

const categoryColors: Record<string, string> = {
    Awareness: "#6366F1",
    Meditation: "#06B6D4",
    Wellness: "#10B981",
    Technology: "#EC4899",
    "Self-Care": "#F59E0B",
};

function renderMarkdown(content: string) {
    // Simple markdown to HTML converter for blog posts
    const lines = content.split("\n");
    const elements: React.ReactNode[] = [];
    let i = 0;
    let inTable = false;
    let tableRows: string[][] = [];

    while (i < lines.length) {
        const line = lines[i];

        // Empty line
        if (line.trim() === "") {
            if (inTable && tableRows.length > 0) {
                elements.push(renderTable(tableRows, elements.length));
                tableRows = [];
                inTable = false;
            }
            i++;
            continue;
        }

        // Table rows
        if (line.trim().startsWith("|") && line.trim().endsWith("|")) {
            const cells = line.split("|").filter(Boolean).map((c) => c.trim());
            // Skip separator rows
            if (cells.every((c) => /^[-:]+$/.test(c))) {
                inTable = true;
                i++;
                continue;
            }
            inTable = true;
            tableRows.push(cells);
            i++;
            continue;
        } else if (inTable && tableRows.length > 0) {
            elements.push(renderTable(tableRows, elements.length));
            tableRows = [];
            inTable = false;
        }

        // Headers
        if (line.startsWith("#### ")) {
            elements.push(
                <h4
                    key={`h4-${i}`}
                    style={{
                        fontSize: "1.05rem",
                        fontWeight: 700,
                        color: "#F1F5F9",
                        marginTop: 28,
                        marginBottom: 10,
                    }}
                >
                    {formatInline(line.slice(5))}
                </h4>
            );
        } else if (line.startsWith("### ")) {
            elements.push(
                <h3
                    key={`h3-${i}`}
                    style={{
                        fontSize: "1.2rem",
                        fontWeight: 700,
                        color: "#F1F5F9",
                        marginTop: 36,
                        marginBottom: 12,
                    }}
                >
                    {formatInline(line.slice(4))}
                </h3>
            );
        } else if (line.startsWith("## ")) {
            elements.push(
                <h2
                    key={`h2-${i}`}
                    className="gradient-text"
                    style={{
                        fontSize: "1.4rem",
                        fontWeight: 800,
                        marginTop: 40,
                        marginBottom: 16,
                    }}
                >
                    {formatInline(line.slice(3))}
                </h2>
            );
        } else if (line.startsWith("- **")) {
            // Bold list items
            elements.push(
                <div
                    key={`li-${i}`}
                    style={{
                        display: "flex",
                        gap: 10,
                        marginBottom: 8,
                        paddingLeft: 4,
                    }}
                >
                    <span style={{ color: "#8B5CF6", fontWeight: 700 }}>•</span>
                    <span
                        style={{
                            fontSize: "0.95rem",
                            color: "rgba(241,245,249,0.7)",
                            lineHeight: 1.7,
                        }}
                    >
                        {formatInline(line.slice(2))}
                    </span>
                </div>
            );
        } else if (line.startsWith("- ")) {
            elements.push(
                <div
                    key={`li-${i}`}
                    style={{
                        display: "flex",
                        gap: 10,
                        marginBottom: 6,
                        paddingLeft: 4,
                    }}
                >
                    <span style={{ color: "#6366F1" }}>•</span>
                    <span
                        style={{
                            fontSize: "0.95rem",
                            color: "rgba(241,245,249,0.65)",
                            lineHeight: 1.7,
                        }}
                    >
                        {formatInline(line.slice(2))}
                    </span>
                </div>
            );
        } else {
            // Regular paragraph
            elements.push(
                <p
                    key={`p-${i}`}
                    style={{
                        fontSize: "0.95rem",
                        color: "rgba(241,245,249,0.65)",
                        lineHeight: 1.8,
                        marginBottom: 12,
                    }}
                >
                    {formatInline(line)}
                </p>
            );
        }
        i++;
    }

    if (inTable && tableRows.length > 0) {
        elements.push(renderTable(tableRows, elements.length));
    }

    return elements;
}

function renderTable(rows: string[][], key: number) {
    if (rows.length === 0) return null;
    const header = rows[0];
    const body = rows.slice(1);

    return (
        <div
            key={`table-${key}`}
            style={{
                overflowX: "auto",
                margin: "20px 0",
                borderRadius: 12,
                border: "1px solid rgba(255,255,255,0.08)",
            }}
        >
            <table
                style={{
                    width: "100%",
                    borderCollapse: "collapse",
                    fontSize: "0.85rem",
                }}
            >
                <thead>
                    <tr>
                        {header.map((cell, ci) => (
                            <th
                                key={ci}
                                style={{
                                    padding: "12px 16px",
                                    textAlign: "left",
                                    color: "#8B5CF6",
                                    fontWeight: 600,
                                    background: "rgba(99,102,241,0.08)",
                                    borderBottom: "1px solid rgba(255,255,255,0.08)",
                                }}
                            >
                                {cell}
                            </th>
                        ))}
                    </tr>
                </thead>
                <tbody>
                    {body.map((row, ri) => (
                        <tr key={ri}>
                            {row.map((cell, ci) => (
                                <td
                                    key={ci}
                                    style={{
                                        padding: "10px 16px",
                                        color: "rgba(241,245,249,0.6)",
                                        borderBottom: "1px solid rgba(255,255,255,0.04)",
                                    }}
                                >
                                    {cell}
                                </td>
                            ))}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}

function formatInline(text: string): React.ReactNode {
    // Handle bold and inline code
    const parts: React.ReactNode[] = [];
    const regex = /(\*\*(.+?)\*\*|`(.+?)`)/g;
    let lastIndex = 0;
    let match: RegExpExecArray | null;

    while ((match = regex.exec(text)) !== null) {
        if (match.index > lastIndex) {
            parts.push(text.slice(lastIndex, match.index));
        }
        if (match[2]) {
            parts.push(
                <strong key={match.index} style={{ color: "#F1F5F9", fontWeight: 600 }}>
                    {match[2]}
                </strong>
            );
        } else if (match[3]) {
            parts.push(
                <code
                    key={match.index}
                    style={{
                        background: "rgba(99,102,241,0.15)",
                        padding: "2px 6px",
                        borderRadius: 4,
                        fontSize: "0.85em",
                        color: "#A5B4FC",
                    }}
                >
                    {match[3]}
                </code>
            );
        }
        lastIndex = match.index + match[0].length;
    }
    if (lastIndex < text.length) {
        parts.push(text.slice(lastIndex));
    }
    return parts.length > 0 ? parts : text;
}

export default function BlogPostClient({ post }: { post: BlogPost }) {
    const catColor = categoryColors[post.category] || "#8B5CF6";

    const articleJsonLd = {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        headline: post.title,
        description: post.excerpt,
        datePublished: post.date,
        author: { "@type": "Person", name: post.author },
        publisher: {
            "@type": "Organization",
            name: "Saathi AI",
            url: "https://saathiai.tech",
        },
        mainEntityOfPage: `https://saathiai.tech/blog/${post.slug}`,
        articleSection: post.category,
        inLanguage: "hi-IN",
    };

    const shareUrl = `https://saathiai.tech/blog/${post.slug}`;
    const shareText = `${post.title} — Saathi AI Blog`;

    const shareLinks = [
        {
            label: "WhatsApp",
            emoji: "💬",
            href: `https://wa.me/?text=${encodeURIComponent(shareText + " " + shareUrl)}`,
        },
        {
            label: "Twitter",
            emoji: "🐦",
            href: `https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}&url=${encodeURIComponent(shareUrl)}`,
        },
        {
            label: "LinkedIn",
            emoji: "💼",
            href: `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`,
        },
    ];

    return (
        <div
            style={{
                minHeight: "100vh",
                paddingTop: 100,
                paddingBottom: 80,
                background: "linear-gradient(180deg, #0F172A 0%, #1E1B4B 50%, #0F172A 100%)",
            }}
        >
            {/* Structured Data */}
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(articleJsonLd) }}
            />

            <div className="section-container" style={{ maxWidth: 720, margin: "0 auto" }}>
                {/* Back link */}
                <motion.div
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.4 }}
                >
                    <Link
                        href="/blog"
                        style={{
                            color: "rgba(241,245,249,0.5)",
                            textDecoration: "none",
                            fontSize: "0.85rem",
                            display: "inline-flex",
                            alignItems: "center",
                            gap: 6,
                            marginBottom: 32,
                            transition: "color 0.2s",
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.color = "#8B5CF6")}
                        onMouseLeave={(e) => (e.currentTarget.style.color = "rgba(241,245,249,0.5)")}
                    >
                        ← Back to Blog
                    </Link>
                </motion.div>

                {/* Header */}
                <motion.div
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6 }}
                    style={{ marginBottom: 40 }}
                >
                    <div
                        style={{
                            fontSize: "4rem",
                            marginBottom: 20,
                            width: 88,
                            height: 88,
                            borderRadius: 22,
                            background: "rgba(99, 102, 241, 0.1)",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                        }}
                    >
                        {post.coverEmoji}
                    </div>

                    <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
                        <span
                            style={{
                                fontSize: "0.7rem",
                                fontWeight: 600,
                                textTransform: "uppercase",
                                letterSpacing: "0.05em",
                                color: catColor,
                                background: `${catColor}15`,
                                padding: "4px 10px",
                                borderRadius: 6,
                            }}
                        >
                            {post.category}
                        </span>
                        <span style={{ fontSize: "0.8rem", color: "rgba(241,245,249,0.3)" }}>
                            {post.readTime}
                        </span>
                    </div>

                    <h1
                        style={{
                            fontSize: "clamp(1.5rem, 4vw, 2.2rem)",
                            fontWeight: 800,
                            color: "#F1F5F9",
                            lineHeight: 1.3,
                            letterSpacing: "-0.02em",
                            marginBottom: 16,
                        }}
                    >
                        {post.title}
                    </h1>

                    <div
                        style={{
                            display: "flex",
                            alignItems: "center",
                            gap: 16,
                            fontSize: "0.8rem",
                            color: "rgba(241,245,249,0.35)",
                        }}
                    >
                        <span>By {post.author}</span>
                        <span>·</span>
                        <span>
                            {new Date(post.date).toLocaleDateString("en-IN", {
                                day: "numeric",
                                month: "long",
                                year: "numeric",
                            })}
                        </span>
                    </div>

                    <div
                        style={{
                            height: 1,
                            background: "linear-gradient(90deg, #6366F1, #EC4899, transparent)",
                            marginTop: 24,
                        }}
                    />
                </motion.div>

                {/* Content */}
                <motion.article
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.2 }}
                >
                    {renderMarkdown(post.content)}
                </motion.article>

                {/* Share Buttons */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.5, delay: 0.3 }}
                    style={{
                        marginTop: 40,
                        padding: "20px 0",
                        borderTop: "1px solid rgba(255,255,255,0.06)",
                    }}
                >
                    <p style={{ fontSize: "0.85rem", color: "rgba(241,245,249,0.4)", marginBottom: 12 }}>
                        Share this article 👇
                    </p>
                    <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
                        {shareLinks.map((s) => (
                            <a
                                key={s.label}
                                href={s.href}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="glass-card"
                                style={{
                                    padding: "8px 16px",
                                    textDecoration: "none",
                                    display: "flex",
                                    alignItems: "center",
                                    gap: 6,
                                    fontSize: "0.8rem",
                                    color: "rgba(241,245,249,0.6)",
                                    borderRadius: 10,
                                    transition: "transform 0.2s, background 0.2s",
                                    cursor: "pointer",
                                }}
                                onMouseEnter={(e) => {
                                    e.currentTarget.style.transform = "translateY(-2px)";
                                    e.currentTarget.style.background = "rgba(255,255,255,0.1)";
                                }}
                                onMouseLeave={(e) => {
                                    e.currentTarget.style.transform = "translateY(0)";
                                    e.currentTarget.style.background = "rgba(255,255,255,0.06)";
                                }}
                            >
                                <span>{s.emoji}</span>
                                <span>{s.label}</span>
                            </a>
                        ))}
                    </div>
                </motion.div>

                {/* CTA */}
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.6, delay: 0.4 }}
                    className="glass-card"
                    style={{
                        marginTop: 24,
                        padding: 32,
                        textAlign: "center",
                    }}
                >
                    <h3 style={{ fontSize: "1.2rem", fontWeight: 700, color: "#F1F5F9", marginBottom: 8 }}>
                        Saathi AI Download Karein 💜
                    </h3>
                    <p style={{ fontSize: "0.9rem", color: "rgba(241,245,249,0.5)", marginBottom: 20 }}>
                        Apni mental wellness journey shuru karein — abhi free mein!
                    </p>
                    <Link
                        href="/"
                        className="cta-button"
                        style={{
                            display: "inline-block",
                            textDecoration: "none",
                            color: "white",
                            fontSize: "0.95rem",
                        }}
                    >
                        Download Saathi AI →
                    </Link>
                </motion.div>
            </div>
        </div>
    );
}
