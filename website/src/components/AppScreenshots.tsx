"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import Image from "next/image";

export default function AppScreenshots() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });

  const x1 = useTransform(scrollYProgress, [0, 1], [0, -1000]);
  const x2 = useTransform(scrollYProgress, [0, 1], [-1000, 0]);

  // We have 14 screenshots, so let's split them into two rows
  const row1 = [1, 2, 3, 4, 5, 6, 7];
  const row2 = [8, 9, 10, 11, 12, 13, 14];

  return (
    <section
      ref={containerRef}
      style={{
        padding: "100px 0",
        overflow: "hidden",
        position: "relative",
        background: "rgba(10, 10, 26, 0.5)",
      }}
    >
      <div style={{ textAlign: "center", marginBottom: 60, padding: "0 24px" }}>
        <h2
          className="gradient-text"
          style={{
            fontSize: "clamp(2rem, 5vw, 3rem)",
            fontWeight: 800,
            marginBottom: 16,
          }}
        >
          Inside Saathi
        </h2>
        <p
          style={{
            color: "rgba(241,245,249,0.5)",
            maxWidth: 600,
            margin: "0 auto",
            fontSize: "1.1rem",
            lineHeight: 1.6,
          }}
        >
          A glimpse into your personal, private mental wellness sanctuary.
          Beautifully designed for peace of mind.
        </p>
      </div>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 40,
          perspective: 1000,
        }}
      >
        {/* First Row */}
        <motion.div
          style={{
            x: x1,
            display: "flex",
            gap: 24,
            paddingLeft: "10vw",
            width: "max-content",
          }}
        >
          {[...row1, ...row1].map((num, idx) => (
            <div
              key={`r1-${idx}`}
              className="glass-card"
              style={{
                width: 260,
                height: 560,
                flexShrink: 0,
                borderRadius: 24,
                overflow: "hidden",
                border: "4px solid rgba(255, 255, 255, 0.1)",
                boxShadow: "0 20px 40px rgba(0,0,0,0.4)",
                position: "relative",
              }}
            >
              <Image
                src={`/screenshots/${num}.jpeg`}
                alt={`Saathi App Screenshot ${num}`}
                fill
                style={{ objectFit: "cover" }}
                unoptimized
              />
            </div>
          ))}
        </motion.div>

        {/* Second Row */}
        <motion.div
          style={{
            x: x2,
            display: "flex",
            gap: 24,
            paddingLeft: "10vw",
            width: "max-content",
          }}
        >
          {[...row2, ...row2].map((num, idx) => (
            <div
              key={`r2-${idx}`}
              className="glass-card"
              style={{
                width: 260,
                height: 560,
                flexShrink: 0,
                borderRadius: 24,
                overflow: "hidden",
                border: "4px solid rgba(255, 255, 255, 0.1)",
                boxShadow: "0 20px 40px rgba(0,0,0,0.4)",
                position: "relative",
              }}
            >
              <Image
                src={`/screenshots/${num}.jpeg`}
                alt={`Saathi App Screenshot ${num}`}
                fill
                style={{ objectFit: "cover" }}
                unoptimized
              />
            </div>
          ))}
        </motion.div>
      </div>

      {/* Edge Gradients */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          bottom: 0,
          width: "15vw",
          background:
            "linear-gradient(to right, rgba(10,10,26,1) 0%, rgba(10,10,26,0) 100%)",
          pointerEvents: "none",
          zIndex: 2,
        }}
      />
      <div
        style={{
          position: "absolute",
          top: 0,
          right: 0,
          bottom: 0,
          width: "15vw",
          background:
            "linear-gradient(to left, rgba(10,10,26,1) 0%, rgba(10,10,26,0) 100%)",
          pointerEvents: "none",
          zIndex: 2,
        }}
      />
    </section>
  );
}
