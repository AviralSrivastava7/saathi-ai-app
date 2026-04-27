"use client";

import { useRef, useEffect, useCallback } from "react";

export default function MagneticTextSection() {
  const containerRef = useRef<HTMLDivElement>(null);
  const cursorRef = useRef<HTMLDivElement>(null);
  const textRef = useRef<HTMLDivElement>(null);
  const cacheRef = useRef<
    { el: HTMLElement; baseX: number; baseY: number }[]
  >([]);
  const animFrameRef = useRef<number>(0);
  const targetRef = useRef({ x: 0, y: 0 });
  const currentRef = useRef({ x: 0, y: 0 });
  const hoveringRef = useRef(false);

  const RADIUS = 75;
  const FIELD_R = 180;
  const MAX_FORCE = 90;

  const buildCache = useCallback(() => {
    if (!textRef.current) return;
    const words = textRef.current.querySelectorAll<HTMLElement>(".word");
    words.forEach((el) => (el.style.transform = "translate(0px, 0px)"));
    const cache: { el: HTMLElement; baseX: number; baseY: number }[] = [];
    words.forEach((el) => {
      cache.push({
        el,
        baseX: el.offsetLeft + el.offsetWidth / 2,
        baseY: el.offsetTop + el.offsetHeight / 2,
      });
    });
    cacheRef.current = cache;
  }, []);

  useEffect(() => {
    if (!textRef.current) return;

    // Wrap every word in spans
    const paragraphs = textRef.current.querySelectorAll("p");
    paragraphs.forEach((p) => {
      const words = p.innerText.split(" ");
      p.innerHTML = words
        .map((w) => `<span class="word">${w}</span>`)
        .join(" ");
    });

    buildCache();

    const handleResize = () => {
      clearTimeout((window as unknown as Record<string, ReturnType<typeof setTimeout>>).__resizeTimer);
      (window as unknown as Record<string, ReturnType<typeof setTimeout>>).__resizeTimer = setTimeout(buildCache, 200);
    };
    window.addEventListener("resize", handleResize);

    // Animation loop
    const animate = () => {
      const cursor = cursorRef.current;
      if (!cursor) {
        animFrameRef.current = requestAnimationFrame(animate);
        return;
      }

      if (hoveringRef.current) {
        currentRef.current.x +=
          (targetRef.current.x - currentRef.current.x) * 0.12;
        currentRef.current.y +=
          (targetRef.current.y - currentRef.current.y) * 0.12;
        cursor.style.transform = `translate(${currentRef.current.x - RADIUS}px, ${currentRef.current.y - RADIUS}px) scale(1)`;
        cursor.style.opacity = "1";
      } else {
        cursor.style.transform = `translate(${currentRef.current.x - RADIUS}px, ${currentRef.current.y - RADIUS}px) scale(0.5)`;
        cursor.style.opacity = "0";
      }
      animFrameRef.current = requestAnimationFrame(animate);
    };
    animFrameRef.current = requestAnimationFrame(animate);

    return () => {
      window.removeEventListener("resize", handleResize);
      cancelAnimationFrame(animFrameRef.current);
    };
  }, [buildCache]);

  const handleMouseMove = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      const container = containerRef.current;
      const textContent = textRef.current;
      if (!container || !textContent) return;

      hoveringRef.current = true;
      const rect = container.getBoundingClientRect();
      const tx = e.clientX - rect.left;
      const ty = e.clientY - rect.top;
      targetRef.current = { x: tx, y: ty };

      const mouseInTextX = tx - textContent.offsetLeft;
      const mouseInTextY = ty - textContent.offsetTop;

      cacheRef.current.forEach((item) => {
        const dx = item.baseX - mouseInTextX;
        const dy = item.baseY - mouseInTextY;
        const distSq = dx * dx + dy * dy;

        if (distSq < FIELD_R * FIELD_R) {
          const dist = Math.sqrt(distSq) || 1;
          const force = Math.pow((FIELD_R - dist) / FIELD_R, 1.8);
          const pushX = (dx / dist) * force * MAX_FORCE;
          const pushY = (dy / dist) * force * MAX_FORCE;
          item.el.style.transform = `translate(${pushX}px, ${pushY}px)`;
        } else {
          item.el.style.transform = "translate(0px, 0px)";
        }
      });
    },
    []
  );

  const handleMouseLeave = useCallback(() => {
    hoveringRef.current = false;
    cacheRef.current.forEach((item) => {
      item.el.style.transform = "translate(0px, 0px)";
    });
  }, []);

  return (
    <section
      style={{
        padding: "80px 24px",
        display: "flex",
        justifyContent: "center",
      }}
    >
      <div
        ref={containerRef}
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
        style={{
          position: "relative",
          maxWidth: 950,
          width: "90vw",
          minHeight: "50vh",
          padding: "50px 60px",
          background: "rgba(255, 255, 255, 0.03)",
          borderRadius: 24,
          border: "1px solid rgba(255, 255, 255, 0.05)",
          backdropFilter: "blur(10px)",
          boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.5)",
          fontSize: "1.15rem",
          lineHeight: 2.2,
          textAlign: "justify" as const,
          touchAction: "none",
          overflow: "hidden",
          boxSizing: "border-box",
          color: "#E2E8F0",
        }}
      >
        <h2
          style={{
            fontWeight: 600,
            fontSize: "clamp(1.8rem, 4vw, 2.8rem)",
            marginBottom: 40,
            marginTop: 0,
            background: "linear-gradient(to right, #A78BFA, #60A5FA)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            textAlign: "center",
            position: "relative",
            zIndex: 2,
          }}
        >
          Meet Saathi
        </h2>

        {/* Saathi Bot Character */}
        <div
          ref={cursorRef}
          style={{
            position: "absolute",
            width: 150,
            height: 150,
            pointerEvents: "none",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            zIndex: 10,
            transition:
              "transform 0.2s cubic-bezier(0.2, 0.8, 0.2, 1), opacity 0.3s",
            top: 0,
            left: 0,
            opacity: 0,
            transform: "scale(0)",
          }}
        >
          {/* Glow ring */}
          <div
            style={{
              position: "absolute",
              width: 130,
              height: 130,
              borderRadius: "50%",
              border: "2px dashed rgba(59, 130, 246, 0.4)",
              animation: "spin 15s linear infinite",
            }}
          />
          {/* Bot body */}
          <div
            style={{
              width: 80,
              height: 80,
              background:
                "linear-gradient(135deg, rgba(124, 58, 237, 0.4), rgba(59, 130, 246, 0.3))",
              borderRadius: "50%",
              backdropFilter: "blur(12px)",
              border: "1px solid rgba(255, 255, 255, 0.2)",
              boxShadow:
                "0 10px 40px rgba(124, 58, 237, 0.5), inset 0 0 20px rgba(255, 255, 255, 0.2)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              animation: "floating 4s ease-in-out infinite",
            }}
          >
            {/* Bot eye */}
            <div
              style={{
                width: 32,
                height: 8,
                background: "#E2E8F0",
                borderRadius: 10,
                boxShadow: "0 0 15px #E2E8F0, 0 0 35px #A78BFA",
                animation: "blink 5s infinite",
              }}
            />
          </div>
        </div>

        <div ref={textRef} style={{ position: "relative", zIndex: 1 }}>
          <p>
            Meet Saathi — Your Private, Offline Mental Health Friend.
            Experience the power of on-device AI running completely without
            the internet. By utilizing state-of-the-art models like Gemma
            directly on your device, Saathi ensures your most private
            thoughts never leave your phone. Voice and image processing
            happen instantly, offline, providing you with a secure,
            responsive, and empathetic companion whenever you need it.
          </p>
          <p>
            In a world where digital privacy is increasingly compromised,
            your mental wellness journey should remain yours alone. This is
            the core philosophy behind Saathi. The system dynamically adapts
            to your emotional state, identifying patterns in your voice and
            text to offer the most comforting responses. All of this heavy
            lifting is performed by algorithms optimized for seamless edge
            computing, turning your mobile device into a sanctuary of peace.
          </p>
          <p>
            Imagine a companion that learns your preferences, recognizes your
            triggers, and helps you navigate anxiety attacks without ever
            sending a single byte of telemetry to a remote server. With
            Saathi, you aren&apos;t just using an app — you are nurturing a
            localized, deeply personal AI entity that listens and responds as
            naturally as a human friend. Take a deep breath, share your
            thoughts, and let your offline companion guide you toward a
            healthier mind.
          </p>
        </div>

        {/* Keyframe animations */}
        <style jsx>{`
          @keyframes floating {
            0%,
            100% {
              transform: translateY(0);
            }
            50% {
              transform: translateY(-8px);
            }
          }
          @keyframes blink {
            0%,
            94%,
            98%,
            100% {
              transform: scaleY(1);
            }
            96% {
              transform: scaleY(0.1);
            }
          }
          @keyframes spin {
            100% {
              transform: rotate(360deg);
            }
          }
        `}</style>
        <style jsx global>{`
          .word {
            display: inline-block;
            transition: transform 0.25s cubic-bezier(0.2, 0.9, 0.3, 1);
            will-change: transform;
            padding: 0 2px;
            margin: 0 -2px;
          }
        `}</style>
      </div>
    </section>
  );
}
