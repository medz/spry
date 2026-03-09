<template>
  <div class="spry-window" aria-hidden="true">
    <div class="spry-window__chrome">
      <div class="spry-window__lights">
        <span></span>
        <span></span>
        <span></span>
      </div>
      <div class="spry-window__tabs">
        <span class="spry-window__tab spry-window__tab--active">routes/index.dart</span>
        <span class="spry-window__tab">spry.config.dart</span>
        <span class="spry-window__tab">.spry/main.dart</span>
      </div>
    </div>
    <div class="spry-window__body">
      <div class="language-dart vp-adaptive-theme">
        <pre class="shiki shiki-themes github-light github-dark vp-code"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">import</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> 'package:spry/spry.dart'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">;</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Response</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> handler</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">Event</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> event) {</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">  return</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> Response</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">.</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">json</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">({</span></span>
<span class="line"><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">    'message'</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> 'hello from spry'</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">,</span></span>
<span class="line"><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">    'runtime'</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> event.context.runtime.name,</span></span>
<span class="line"><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">    'path'</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">:</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> event.request.url.path,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  });</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;">// dart run spry serve</span></span></code></pre>
      </div>
    </div>
    <div class="spry-window__footer">
      <span>Dart routes</span>
      <span>Generated app</span>
      <span>Node / Bun / Dart</span>
      <span>Cloudflare / Vercel</span>
    </div>
  </div>
</template>
