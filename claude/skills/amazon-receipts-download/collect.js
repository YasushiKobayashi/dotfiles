// Amazon.co.jp の「注文の詳細」タブで javascript_tool から実行する。
// 領収書等メニューを開き、請求書 PDF があれば PDF を、無ければ「印刷可能な注文概要」の HTML を
// amazon_<注文日>_<注文番号>.(pdf|html) としてブラウザの既定ダウンロード先へ保存する。
// 戻り値に URL（クエリ文字列付き）を含めると tool 出力が BLOCKED になるので、ファイル名とサイズだけ返す。
const oid = new URLSearchParams(location.search).get('orderID');
const trigger = [...document.querySelectorAll('a')].find(a => a.textContent.trim() === '領収書等');
trigger && trigger.click();

// ポップオーバーは遅延ロード。デジタル注文でも PDF が出ることがあるので、印刷リンクだけ見えても最低 2 秒は PDF を待つ
let pdf = [], print;
for (let i = 0; i < 16; i++) {
  await new Promise(r => setTimeout(r, 500));
  pdf = [...document.querySelectorAll('a')].filter(a => /\/documents\/download\/.*\.pdf/.test(a.getAttribute('href') || ''));
  print = [...document.querySelectorAll('a')].find(a => /印刷可能な注文概要/.test(a.textContent));
  if (pdf.length || (print && i >= 3)) break;
}

const m = document.body.innerText.match(/注文日\s*(\d{4})年(\d{1,2})月(\d{1,2})日/);
const date = m ? `${m[1]}${m[2].padStart(2, '0')}${m[3].padStart(2, '0')}` : 'nodate';
const save = (blob, name) => {
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = name;
  document.body.appendChild(a);
  a.click();
  a.remove();
};

const out = [];
if (pdf.length) {
  for (const [i, a] of pdf.entries()) {
    const res = await fetch(a.href, { credentials: 'include' });
    const blob = await res.blob();
    const name = `amazon_${date}_${oid}${pdf.length > 1 ? '_' + (i + 1) : ''}.pdf`;
    if (blob.type !== 'application/pdf') { out.push(`NG ${name} ${res.status} ${blob.type}`); continue; }
    save(blob, name);
    await new Promise(r => setTimeout(r, 800));
    out.push(`PDF ${name} ${blob.size}`);
  }
} else if (print) {
  const res = await fetch(print.href, { credentials: 'include' });
  const html = (await res.text())
    .replace(/<script[\s\S]*?<\/script>/gi, '')
    .replace(/<head([^>]*)>/i, '<head$1><base href="https://www.amazon.co.jp/">');
  const name = `amazon_${date}_${oid}.html`;
  save(new Blob([html], { type: 'text/html' }), name);
  out.push(`HTML ${name} ${html.length}`);
} else {
  out.push(`NONE ${oid}`);
}
out.join('\n');
