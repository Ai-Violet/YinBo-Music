/**
 * 区分 LRC 原文与中文翻译：中文比例高的一侧作为「译」，另一侧作为「原唱词」。
 */
const CJK_RE = /[\u3040-\u30ff\u31f0-\u31ff\u3400-\u4dbf\u4e00-\u9fff\uff00-\uffef]/

function nonSpaceChars(s: string): string[] {
  return [...s].filter((c) => !/\s/.test(c))
}

export function isMostlyCjk(s: string): boolean {
  const chars = nonSpaceChars(s)
  if (chars.length === 0) return false
  let cjk = 0
  for (const c of chars) {
    if (CJK_RE.test(c)) cjk++
  }
  return cjk / chars.length >= 0.34
}

/** 返回 { text: 原词, translation: 译文 }，无译文时 translation 为 undefined */
export function pairLyricLine(
  partA: string,
  partB: string
): { text: string; translation: string | undefined } {
  const a = partA.trim()
  const b = partB.trim()
  if (!b) return { text: a, translation: undefined }
  const aCjk = isMostlyCjk(a)
  const bCjk = isMostlyCjk(b)
  if (aCjk && !bCjk) return { text: b, translation: a }
  if (!aCjk && bCjk) return { text: a, translation: b }
  if (aCjk && bCjk) {
    const score = (t: string) => (isMostlyCjk(t) ? nonSpaceChars(t).length : 0)
    if (score(a) > score(b) * 1.15) return { text: b, translation: a }
    if (score(b) > score(a) * 1.15) return { text: a, translation: b }
  }
  return { text: a, translation: b }
}
