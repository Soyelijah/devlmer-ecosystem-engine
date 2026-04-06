/**
 * Devlmer Ecosystem Engine - Install Wizard
 * Modal wizard with terminal selector, one-liner copy,
 * command preview, and live installation simulation
 */

// ==================== INSTALL WIZARD ====================
const wizardState = {
    currentStep: 1,
    os: null,
    method: 'cli',
    path: ''
};

const REPO_URL = 'https://github.com/Soyelijah/devlmer-ecosystem-engine.git';
const ZIP_URL = 'https://github.com/Soyelijah/devlmer-ecosystem-engine/archive/refs/heads/main.zip';

function openWizard() {
    const overlay = document.getElementById('installWizard');
    overlay.classList.add('active');
    document.body.style.overflow = 'hidden';
    wizardGoTo(1);
    // Try to detect OS
    const ua = navigator.userAgent.toLowerCase();
    if (ua.includes('mac')) autoSelectOS('macos');
    else if (ua.includes('win')) autoSelectOS('windows');
    else if (ua.includes('linux')) autoSelectOS('linux');
}

function closeWizard() {
    const overlay = document.getElementById('installWizard');
    overlay.classList.remove('active');
    document.body.style.overflow = '';
}

// Close on Escape
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeWizard();
});

function autoSelectOS(os) {
    const card = document.querySelector(`.os-card[data-os="${os}"]`);
    if (card) selectOS(card);
}

function selectOS(el) {
    document.querySelectorAll('.os-card').forEach(c => c.classList.remove('selected'));
    el.classList.add('selected');
    wizardState.os = el.dataset.os;

    // Set placeholder path based on OS
    const pathInput = document.getElementById('projectPath');
    const placeholders = {
        macos: '/Users/you/projects/my-app',
        linux: '/home/you/projects/my-app',
        windows: '/mnt/c/Users/you/projects/my-app'
    };
    pathInput.placeholder = placeholders[wizardState.os] || '/path/to/project';

    // Show path suggestions
    renderPathSuggestions();
    updateNextBtn();
}

function renderPathSuggestions() {
    const suggestions = {
        macos: [
            { icon: 'fa-code', path: '~/Developer/my-project' },
            { icon: 'fa-folder', path: '~/Projects/my-app' },
            { icon: 'fa-desktop', path: '~/Desktop/my-project' },
            { icon: 'fa-download', path: '~/Downloads/my-project' },
            { icon: 'fa-terminal', path: '$(pwd)' },
        ],
        linux: [
            { icon: 'fa-code', path: '~/dev/my-project' },
            { icon: 'fa-folder', path: '~/projects/my-app' },
            { icon: 'fa-home', path: '~/my-project' },
            { icon: 'fa-server', path: '/var/www/my-app' },
            { icon: 'fa-terminal', path: '$(pwd)' },
        ],
        windows: [
            { icon: 'fa-code', path: '/mnt/c/dev/my-project' },
            { icon: 'fa-folder', path: '/mnt/c/Users/you/projects/my-app' },
            { icon: 'fa-desktop', path: '/mnt/c/Users/you/Desktop/my-project' },
            { icon: 'fa-terminal', path: '$(pwd)' },
        ]
    };

    const list = document.getElementById('pathSuggestionsList');
    const container = document.getElementById('pathSuggestions');
    const items = suggestions[wizardState.os] || [];

    list.innerHTML = items.map(s =>
        `<div class="path-chip" onclick="useSuggestedPath('${s.path}')">
            <i class="fas ${s.icon}"></i> ${s.path}
        </div>`
    ).join('');

    container.classList.add('visible');
}

function useSuggestedPath(path) {
    const input = document.getElementById('projectPath');
    input.value = path;
    input.focus();
    // Brief highlight animation
    input.style.borderColor = 'var(--primary-cyan)';
    input.style.boxShadow = '0 0 25px rgba(0, 212, 170, 0.2)';
    setTimeout(() => {
        input.style.borderColor = '';
        input.style.boxShadow = '';
    }, 800);
}

async function browseFolder() {
    const btn = document.getElementById('pathBrowseBtn');

    // Check if File System Access API is available (Chrome, Edge, Opera)
    if ('showDirectoryPicker' in window) {
        try {
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Buscando...';
            const dirHandle = await window.showDirectoryPicker({ mode: 'read' });
            const folderName = dirHandle.name;

            // Build a display path based on OS
            const basePaths = {
                macos: `/Users/${folderName}`,
                linux: `/home/${folderName}`,
                windows: `/mnt/c/Users/${folderName}`
            };

            // Try to show folder name in the input
            const input = document.getElementById('projectPath');
            // We can't get the full path from the API, but we have the folder name
            const currentVal = input.value;
            if (!currentVal) {
                // Suggest a smart path
                const base = {
                    macos: '~/Projects/',
                    linux: '~/projects/',
                    windows: '/mnt/c/Users/you/projects/'
                };
                input.value = (base[wizardState.os] || '~/') + folderName;
            } else {
                // Append to current path if it ends with /
                if (currentVal.endsWith('/')) {
                    input.value = currentVal + folderName;
                } else {
                    input.value = currentVal;
                }
            }

            btn.innerHTML = '<i class="fas fa-check"></i> ' + folderName;
            btn.style.borderColor = 'var(--primary-cyan)';
            btn.style.background = 'rgba(0, 212, 170, 0.15)';

            setTimeout(() => {
                btn.innerHTML = '<i class="fas fa-folder-plus"></i> Buscar';
                btn.style.borderColor = '';
                btn.style.background = '';
            }, 3000);

        } catch (err) {
            // User cancelled the picker
            btn.innerHTML = '<i class="fas fa-folder-plus"></i> Buscar';
        }
    } else {
        // Fallback: show a helpful tooltip/message
        btn.innerHTML = '<i class="fas fa-info-circle"></i> Escríbela';
        btn.style.borderColor = 'rgba(255, 190, 50, 0.4)';

        // Show a brief tooltip
        const tooltip = document.createElement('div');
        tooltip.style.cssText = `
            position: absolute; bottom: calc(100% + 10px); right: 0;
            background: rgba(17, 25, 51, 0.98); border: 1px solid rgba(255, 190, 50, 0.3);
            border-radius: 10px; padding: 12px 16px; width: 280px;
            font-size: 0.78rem; color: var(--text-secondary); line-height: 1.5;
            box-shadow: 0 8px 30px rgba(0,0,0,0.4); z-index: 10;
            animation: wizardFadeIn 0.3s ease;
        `;
        tooltip.innerHTML = `
            <div style="color: #febe2e; font-weight: 600; margin-bottom: 6px;">
                <i class="fas fa-lightbulb"></i> Tip
            </div>
            Tu navegador no soporta el selector de carpetas. Escribe la ruta manualmente o usa <code style="color: var(--primary-cyan); background: rgba(0,212,170,0.1); padding: 2px 6px; border-radius: 4px;">$(pwd)</code> para usar el directorio actual.
        `;
        btn.parentElement.style.position = 'relative';
        btn.parentElement.appendChild(tooltip);

        setTimeout(() => {
            tooltip.style.opacity = '0';
            tooltip.style.transition = 'opacity 0.3s';
            setTimeout(() => tooltip.remove(), 300);
            btn.innerHTML = '<i class="fas fa-folder-plus"></i> Buscar';
            btn.style.borderColor = '';
        }, 4000);
    }
}

function selectMethod(el) {
    document.querySelectorAll('.method-card').forEach(c => c.classList.remove('selected'));
    el.classList.add('selected');
    wizardState.method = el.dataset.method;
}

function updateNextBtn() {
    const btn = document.getElementById('wizardBtnNext');
    if (wizardState.currentStep === 1) {
        btn.disabled = !wizardState.os;
    } else {
        btn.disabled = false;
    }
}

function wizardNext() {
    if (wizardState.currentStep === 1) {
        wizardState.path = document.getElementById('projectPath').value.trim();
    }

    if (wizardState.currentStep < 3) {
        wizardGoTo(wizardState.currentStep + 1);
    }
}

function wizardBack() {
    if (wizardState.currentStep > 1) {
        wizardGoTo(wizardState.currentStep - 1);
    }
}

function wizardGoTo(step) {
    wizardState.currentStep = step;

    // Update dots
    document.querySelectorAll('.wizard-step-dot').forEach(dot => {
        const s = parseInt(dot.dataset.step);
        dot.classList.remove('active', 'completed');
        if (s === step) dot.classList.add('active');
        else if (s < step) {
            dot.classList.add('completed');
            dot.innerHTML = '<i class="fas fa-check" style="font-size:0.65rem"></i>';
        } else {
            dot.textContent = s;
        }
    });

    // Update lines
    document.querySelectorAll('.wizard-step-line').forEach(line => {
        const l = parseInt(line.dataset.line);
        line.classList.toggle('completed', l < step);
    });

    // Update labels
    const labels = document.querySelectorAll('.wizard-step-label');
    labels.forEach((lbl, i) => {
        lbl.classList.toggle('active', i + 1 === step);
    });

    // Show/hide content
    document.querySelectorAll('.wizard-step-content').forEach(content => {
        const s = parseInt(content.dataset.step);
        content.classList.toggle('active', s === step);
    });

    // Back button visibility
    document.getElementById('wizardBtnBack').style.visibility = step > 1 ? 'visible' : 'hidden';

    // Footer button
    const nextBtn = document.getElementById('wizardBtnNext');
    if (step === 3) {
        // Render terminal options for selected OS
        renderTerminalOptions();
        wizardState.terminal = null;
        document.getElementById('onelinerBlock').style.display = 'none';

        // Set footer based on active tab
        const activeTab = document.querySelector('.exec-tab.active');
        const tab = activeTab ? activeTab.dataset.tab : 'auto';
        updateStep3Footer(tab);
        renderTerminal();
    } else {
        nextBtn.className = 'wizard-btn wizard-btn-next';
        nextBtn.innerHTML = 'Siguiente <i class="fas fa-arrow-right"></i>';
        nextBtn.onclick = wizardNext;
        updateNextBtn();
    }
}

// ==================== EXEC TABS ====================
function switchExecTab(tab) {
    document.querySelectorAll('.exec-tab').forEach(t => t.classList.remove('active'));
    document.querySelector(`.exec-tab[data-tab="${tab}"]`).classList.add('active');

    document.querySelectorAll('.exec-panel').forEach(p => p.classList.remove('active'));
    document.getElementById('panel' + tab.charAt(0).toUpperCase() + tab.slice(1)).classList.add('active');

    // Start simulation when preview tab is opened
    if (tab === 'preview') {
        setTimeout(() => startSimulation(), 300);
    }

    // Update footer button based on active tab
    updateStep3Footer(tab);
}

function updateStep3Footer(tab) {
    const nextBtn = document.getElementById('wizardBtnNext');
    if (wizardState.currentStep !== 3) return;

    if (tab === 'auto') {
        if (wizardState.terminal) {
            const os = wizardState.os || 'linux';
            const terminals = TERMINALS[os] || TERMINALS.linux;
            const t = terminals.find(x => x.id === wizardState.terminal);
            nextBtn.className = 'wizard-btn wizard-btn-copy-final';
            nextBtn.innerHTML = '<i class="fas fa-copy"></i> Copiar comando para ' + (t ? t.name : 'Terminal');
            nextBtn.onclick = copyOneliner;
            nextBtn.disabled = false;
        } else {
            nextBtn.className = 'wizard-btn wizard-btn-next';
            nextBtn.innerHTML = '<i class="fas fa-hand-pointer"></i> Selecciona tu terminal';
            nextBtn.disabled = true;
        }
    } else if (tab === 'copy') {
        nextBtn.className = 'wizard-btn wizard-btn-copy-final';
        nextBtn.innerHTML = '<i class="fas fa-copy"></i> Copiar comando completo';
        nextBtn.onclick = copyFinalCommand;
        nextBtn.disabled = false;
    } else {
        nextBtn.className = 'wizard-btn wizard-btn-next';
        nextBtn.innerHTML = '<i class="fas fa-eye"></i> Simulando...';
        nextBtn.disabled = true;
    }
}

// ==================== TERMINAL SELECTOR ====================
const TERMINALS = {
    macos: [
        { id: 'terminal', name: 'Terminal', icon: '>', color: '#fff', bg: '#1d1d1d', shortcut: '⌘ + Space → "Terminal"' },
        { id: 'iterm2', name: 'iTerm2', icon: '⟩', color: '#2bff2b', bg: '#000', shortcut: '⌘ + Space → "iTerm"' },
        { id: 'warp', name: 'Warp', icon: 'W', color: '#01c38d', bg: '#191919', shortcut: '⌘ + Space → "Warp"' },
        { id: 'vscode', name: 'VS Code', icon: '⟨⟩', color: '#007acc', bg: '#1e1e1e', shortcut: 'Ctrl + ` en VS Code' },
        { id: 'hyper', name: 'Hyper', icon: 'H', color: '#fff', bg: '#000', shortcut: '⌘ + Space → "Hyper"' },
    ],
    linux: [
        { id: 'gnome', name: 'GNOME Term', icon: '▸', color: '#fff', bg: '#2e3436', shortcut: 'Ctrl + Alt + T' },
        { id: 'konsole', name: 'Konsole', icon: 'K', color: '#1d99f3', bg: '#232629', shortcut: 'Ctrl + Alt + T' },
        { id: 'alacritty', name: 'Alacritty', icon: 'A', color: '#f0c674', bg: '#1d1f21', shortcut: 'Launcher → "Alacritty"' },
        { id: 'kitty', name: 'Kitty', icon: '🐱', color: '#fff', bg: '#000', shortcut: 'Launcher → "Kitty"' },
        { id: 'vscode', name: 'VS Code', icon: '⟨⟩', color: '#007acc', bg: '#1e1e1e', shortcut: 'Ctrl + ` en VS Code' },
    ],
    windows: [
        { id: 'wt', name: 'Windows Terminal', icon: '⟩_', color: '#0078d4', bg: '#0c0c0c', shortcut: 'Win + R → "wt"' },
        { id: 'wsl', name: 'WSL', icon: '🐧', color: '#e95420', bg: '#2c001e', shortcut: 'wsl en Windows Terminal' },
        { id: 'gitbash', name: 'Git Bash', icon: 'G', color: '#f14e32', bg: '#0d1117', shortcut: 'Menú inicio → "Git Bash"' },
        { id: 'powershell', name: 'PowerShell', icon: 'PS', color: '#012456', bg: '#012456', shortcut: 'Win + X → Terminal' },
        { id: 'vscode', name: 'VS Code', icon: '⟨⟩', color: '#007acc', bg: '#1e1e1e', shortcut: 'Ctrl + ` en VS Code' },
    ]
};

function renderTerminalOptions() {
    const grid = document.getElementById('terminalGrid');
    const os = wizardState.os || 'linux';
    const terminals = TERMINALS[os] || TERMINALS.linux;

    grid.innerHTML = terminals.map(t => `
        <div class="terminal-option" data-terminal="${t.id}" onclick="selectTerminal(this, '${t.id}')">
            <div class="term-icon" style="background:${t.bg}; color:${t.color}; border: 1px solid rgba(255,255,255,0.1);">
                ${t.icon}
            </div>
            <span class="term-name">${t.name}</span>
        </div>
    `).join('');
}

function selectTerminal(el, termId) {
    document.querySelectorAll('.terminal-option').forEach(c => c.classList.remove('selected'));
    el.classList.add('selected');
    wizardState.terminal = termId;

    const os = wizardState.os || 'linux';
    const terminals = TERMINALS[os] || TERMINALS.linux;
    const term = terminals.find(t => t.id === termId);
    const p = wizardState.path || '~/projects/my-app';

    // Show the one-liner block
    const block = document.getElementById('onelinerBlock');
    block.style.display = 'block';

    // Update paste hint
    const hint = document.getElementById('onelinerHint');
    const isMac = os === 'macos';
    hint.innerHTML = `Pega con <kbd>${isMac ? '⌘V' : 'Ctrl+V'}</kbd> en ${term.name}`;

    // Generate the one-liner
    const codeEl = document.getElementById('onelinerCode');
    const cmd = `rm -rf /tmp/dee && git clone ${REPO_URL} /tmp/dee && bash /tmp/dee/install.sh "${p}"`;
    codeEl.innerHTML = `<span class="ol-prompt">$ </span><span class="ol-cmd">git clone</span> <span class="ol-url">${REPO_URL}</span> <span class="ol-path">/tmp/dee</span> <span class="ol-cmd">&&</span> <span class="ol-cmd">bash</span> <span class="ol-path">/tmp/dee/install.sh</span> <span class="ol-path">"${p}"</span>`;

    // Render steps
    const stepsEl = document.getElementById('onelinerSteps');
    stepsEl.innerHTML = `
        <div class="oneliner-step">
            <div class="step-num">1</div>
            <div class="step-text"><strong>Copia</strong>Click en el botón de abajo</div>
        </div>
        <div class="oneliner-step">
            <div class="step-num">2</div>
            <div class="step-text"><strong>Abre ${term.name}</strong>${term.shortcut}</div>
        </div>
        <div class="oneliner-step">
            <div class="step-num">3</div>
            <div class="step-text"><strong>Pega y Enter</strong>${isMac ? '⌘V' : 'Ctrl+V'} → Enter</div>
        </div>
    `;

    // Update footer btn
    const nextBtn = document.getElementById('wizardBtnNext');
    if (wizardState.currentStep === 3) {
        nextBtn.className = 'wizard-btn wizard-btn-copy-final';
        nextBtn.innerHTML = '<i class="fas fa-copy"></i> Copiar comando para ' + term.name;
        nextBtn.onclick = copyOneliner;
        nextBtn.disabled = false;
    }
}

function copyOneliner() {
    const p = wizardState.path || '~/projects/my-app';
    const cmd = `rm -rf /tmp/dee && git clone ${REPO_URL} /tmp/dee && bash /tmp/dee/install.sh "${p}"`;

    navigator.clipboard.writeText(cmd).then(() => {
        const btn = document.getElementById('onelinerCopyBtn');
        const footerBtn = document.getElementById('wizardBtnNext');

        btn.classList.add('downloaded');
        btn.innerHTML = '<i class="fas fa-check-circle"></i> ¡Copiado! Ahora pega en tu terminal';

        if (footerBtn && wizardState.currentStep === 3) {
            footerBtn.classList.add('copied');
            footerBtn.style.background = 'linear-gradient(135deg, #28c840, #1fa032)';
            footerBtn.innerHTML = '<i class="fas fa-check"></i> Copiado al portapapeles';
        }

        setTimeout(() => {
            btn.classList.remove('downloaded');
            btn.innerHTML = '<i class="fas fa-copy"></i> Copiar al portapapeles';
            if (footerBtn) {
                footerBtn.classList.remove('copied');
                footerBtn.style.background = '';
                const term = wizardState.terminal || 'terminal';
                const os = wizardState.os || 'linux';
                const terminals = TERMINALS[os] || TERMINALS.linux;
                const t = terminals.find(x => x.id === term);
                footerBtn.innerHTML = '<i class="fas fa-copy"></i> Copiar comando para ' + (t ? t.name : 'Terminal');
            }
        }, 3500);
    });
}

// ==================== XTERM SIMULATION ====================
let simRunning = false;

async function startSimulation() {
    if (simRunning) return;
    simRunning = true;
    const body = document.getElementById('xtermBody');
    body.innerHTML = '';
    const p = wizardState.path || '~/Projects/my-app';

    const lines = [
        { text: '', delay: 200 },
        { text: '<span class="xt-cyan xt-bold">⚡ Devlmer Ecosystem Engine — Auto-Installer</span>', delay: 80 },
        { text: '<span class="xt-cyan">━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</span>', delay: 40 },
        { text: '', delay: 150 },
        { text: '<span class="xt-prompt">▶</span> <span class="xt-cmd">Clonando repositorio...</span>', delay: 600, typing: true },
        { text: '<span class="xt-dim">  Cloning into \'/tmp/dee\'...</span>', delay: 400 },
        { text: '<span class="xt-dim">  remote: Enumerating objects: 165, done.</span>', delay: 200 },
        { text: '<span class="xt-dim">  remote: Counting objects: 100% (165/165), done.</span>', delay: 200 },
        { text: '<span class="xt-dim">  Receiving objects: 100% (165/165), 284.5 KiB, done.</span>', delay: 300 },
        { text: '<span class="xt-success">✓ Repositorio clonado</span>', delay: 150 },
        { text: '', delay: 100 },
        { text: '<span class="xt-prompt">▶</span> <span class="xt-cmd">Ejecutando instalador...</span>', delay: 500, typing: true },
        { text: '', delay: 100 },
        { text: '<span class="xt-cyan xt-bold">╔══════════════════════════════════════════╗</span>', delay: 50 },
        { text: '<span class="xt-cyan xt-bold">║  DEVLMER ECOSYSTEM ENGINE v3.0           ║</span>', delay: 50 },
        { text: '<span class="xt-cyan xt-bold">║  Professional Toolsets for Claude Code    ║</span>', delay: 50 },
        { text: '<span class="xt-cyan xt-bold">╚══════════════════════════════════════════╝</span>', delay: 200 },
        { text: '', delay: 100 },
        { text: '<span class="xt-info">[1/7]</span> Detecting platform...', delay: 300 },
        { text: '  <span class="xt-success">✓</span> macOS arm64 detected (Bash 5.2)', delay: 200 },
        { text: '<span class="xt-info">[2/7]</span> Scanning project...', delay: 400, typing: true },
        { text: '  <span class="xt-success">✓</span> Fingerprint: <span class="xt-cyan">React + FastAPI (Trading Platform)</span>', delay: 300 },
        { text: '  <span class="xt-dim">  Confidence: 94% | Domain: fintech</span>', delay: 200 },
        { text: '<span class="xt-info">[3/7]</span> Installing 21 professional skills...', delay: 200, typing: true },
        { text: '', delay: 50 },
        { progress: true, items: [
            'senior-architect', 'senior-frontend', 'senior-backend',
            'senior-security', 'code-reviewer', 'senior-fullstack',
            'senior-prompt-engineer', 'ui-ux-pro-max', 'ui-design-system',
            'copywriting', 'seo-optimizer', 'brand-identity',
            'brainstorming', 'file-organizer', 'mobile-design',
            'marketing-graphic-design', 'git-commit-helper',
            'mcp-builder', 'skill-creator', 'project-intelligence',
            'webapp-testing'
        ]},
        { text: '  <span class="xt-success">✓</span> 21/21 skills installed', delay: 200 },
        { text: '<span class="xt-info">[4/7]</span> Configuring 23 MCP integrations...', delay: 300, typing: true },
        { text: '  <span class="xt-success">✓</span> GitHub, Playwright, Cloudflare, Notion...', delay: 200 },
        { text: '<span class="xt-info">[5/7]</span> Setting up hooks...', delay: 300 },
        { text: '  <span class="xt-success">✓</span> PreToolUse, PostToolUse, SessionStart', delay: 200 },
        { text: '<span class="xt-info">[6/7]</span> Generating CLAUDE.md...', delay: 400 },
        { text: '  <span class="xt-success">✓</span> Auto-configured for <span class="xt-cyan">fintech</span> domain', delay: 200 },
        { text: '<span class="xt-info">[7/7]</span> Running verification...', delay: 500, typing: true },
        { text: '  <span class="xt-success">✓</span> All components verified', delay: 300 },
        { text: '', delay: 100 },
        { text: '<span class="xt-success xt-bold">═══════════════════════════════════════════</span>', delay: 50 },
        { text: '<span class="xt-success xt-bold">  ✓ Installation complete! (58s)</span>', delay: 50 },
        { text: '<span class="xt-success xt-bold">═══════════════════════════════════════════</span>', delay: 100 },
        { text: '', delay: 50 },
        { text: '  <span class="xt-cyan">Project:</span>  ' + p, delay: 100 },
        { text: '  <span class="xt-cyan">Skills:</span>   21 installed', delay: 80 },
        { text: '  <span class="xt-cyan">MCPs:</span>     23 configured', delay: 80 },
        { text: '  <span class="xt-cyan">Hooks:</span>    3 active', delay: 80 },
        { text: '', delay: 150 },
        { text: '  <span class="xt-dim">Open Claude Code in your project to start.</span>', delay: 100 },
        { text: '', delay: 50 },
    ];

    for (const line of lines) {
        if (!simRunning) break;

        if (line.progress) {
            await renderProgressBlock(body, line.items);
            continue;
        }

        const div = document.createElement('div');
        div.className = 'xterm-line';

        if (line.typing && line.text) {
            await typewriterLine(div, line.text, body);
        } else {
            div.innerHTML = line.text || '&nbsp;';
            body.appendChild(div);
        }

        body.scrollTop = body.scrollHeight;
        await sleep(line.delay || 50);
    }

    // Add blinking cursor at end
    const cursor = document.createElement('span');
    cursor.className = 'xterm-cursor';
    cursor.innerHTML = '&nbsp;';
    const lastLine = body.lastElementChild || body;
    lastLine.appendChild(cursor);

    simRunning = false;

    // Enable footer button
    const footerBtn = document.getElementById('wizardBtnNext');
    if (footerBtn && wizardState.currentStep === 3) {
        footerBtn.className = 'wizard-btn wizard-btn-copy-final';
        footerBtn.innerHTML = '<i class="fas fa-redo"></i> Reproducir de nuevo';
        footerBtn.disabled = false;
        footerBtn.onclick = replaySimulation;
    }
}

async function typewriterLine(div, html, container) {
    // Parse the HTML to extract text content for typing
    const temp = document.createElement('div');
    temp.innerHTML = html;
    const fullText = temp.textContent;

    div.innerHTML = '';
    container.appendChild(div);

    // Type character by character with the original HTML structure
    for (let i = 0; i <= fullText.length; i++) {
        div.innerHTML = html.substring(0, html.length * (i / fullText.length)) || html.substring(0, i * 3);
        container.scrollTop = container.scrollHeight;
        await sleep(15 + Math.random() * 20);
    }
    div.innerHTML = html;
}

async function renderProgressBlock(container, items) {
    const wrapper = document.createElement('div');
    wrapper.className = 'xterm-line';
    wrapper.style.marginLeft = '16px';
    container.appendChild(wrapper);

    for (let i = 0; i < items.length; i++) {
        const pct = Math.round(((i + 1) / items.length) * 100);
        const barWidth = Math.round((pct / 100) * 20);
        const bar = '█'.repeat(barWidth) + '░'.repeat(20 - barWidth);
        wrapper.innerHTML = `<span class="xt-dim">[${bar}]</span> <span class="xt-cyan">${pct}%</span> <span class="xt-info">${items[i]}</span>`;
        container.scrollTop = container.scrollHeight;
        await sleep(80 + Math.random() * 60);
    }
    wrapper.innerHTML = `<span class="xt-dim">[${'█'.repeat(20)}]</span> <span class="xt-success">100%</span> <span class="xt-success">All skills installed</span>`;
}

function replaySimulation() {
    simRunning = false;
    setTimeout(() => startSimulation(), 100);
}

function sleep(ms) {
    return new Promise(r => setTimeout(r, ms));
}

function getInstallCommand() {
    const p = wizardState.path || '/ruta/a/tu/proyecto';

    if (wizardState.method === 'cli') {
        return `rm -rf /tmp/dee && git clone ${REPO_URL} /tmp/dee && bash /tmp/dee/install.sh "${p}"`;
    } else {
        return `# 1. Descarga desde:\n#    ${ZIP_URL}\n# 2. Descomprime y ejecuta:\ncd devlmer-ecosystem-engine-main && bash install.sh "${p}"`;
    }
}

function renderTerminal() {
    const body = document.getElementById('terminalBody');
    const title = document.getElementById('terminalTitle');
    const p = wizardState.path || '/ruta/a/tu/proyecto';
    const shells = { macos: 'zsh', linux: 'bash', windows: 'bash (WSL)' };
    title.textContent = `Terminal — ${shells[wizardState.os] || 'bash'}`;

    let lines = [];

    if (wizardState.method === 'cli') {
        lines = [
            { type: 'comment', text: '# Clona el repositorio e instala en un solo comando' },
            { type: 'cmd', parts: [
                { text: 'git clone ', cls: 'cmd' },
                { text: REPO_URL, cls: 'url-val' },
                { text: ' /tmp/dee', cls: 'path-val' }
            ]},
            { type: 'blank' },
            { type: 'comment', text: '# Ejecuta el instalador' },
            { type: 'cmd', parts: [
                { text: 'bash ', cls: 'cmd' },
                { text: '/tmp/dee/install.sh ', cls: 'path-val' },
                { text: p, cls: 'path-val' }
            ]},
        ];
    } else {
        lines = [
            { type: 'comment', text: '# 1. Descarga el .zip desde GitHub:' },
            { type: 'cmd', parts: [
                { text: 'curl ', cls: 'cmd' },
                { text: '-L ', cls: 'flag' },
                { text: '-o ', cls: 'flag' },
                { text: 'dee.zip ', cls: 'path-val' },
                { text: ZIP_URL, cls: 'url-val' }
            ]},
            { type: 'blank' },
            { type: 'comment', text: '# 2. Descomprime:' },
            { type: 'cmd', parts: [
                { text: 'unzip ', cls: 'cmd' },
                { text: 'dee.zip', cls: 'path-val' }
            ]},
            { type: 'blank' },
            { type: 'comment', text: '# 3. Ejecuta el instalador:' },
            { type: 'cmd', parts: [
                { text: 'cd ', cls: 'cmd' },
                { text: 'devlmer-ecosystem-engine-main ', cls: 'path-val' },
                { text: '&& bash ', cls: 'cmd' },
                { text: 'install.sh ', cls: 'path-val' },
                { text: p, cls: 'path-val' }
            ]},
        ];
    }

    body.innerHTML = '';

    lines.forEach((line, i) => {
        const div = document.createElement('div');
        div.className = 'line';
        div.style.animationDelay = `${i * 0.08}s`;

        if (line.type === 'blank') {
            div.innerHTML = '&nbsp;';
        } else if (line.type === 'comment') {
            div.innerHTML = `<span class="comment">${line.text}</span>`;
        } else if (line.type === 'cmd') {
            let html = '<span class="prompt">$</span> ';
            line.parts.forEach(part => {
                html += `<span class="${part.cls}">${part.text}</span>`;
            });
            div.innerHTML = html;
        }

        body.appendChild(div);
    });
}

function copyFinalCommand() {
    const p = wizardState.path || '/ruta/a/tu/proyecto';
    let cmd;

    if (wizardState.method === 'cli') {
        cmd = `rm -rf /tmp/dee && git clone ${REPO_URL} /tmp/dee && bash /tmp/dee/install.sh "${p}"`;
    } else {
        cmd = `curl -L -o dee.zip ${ZIP_URL} && unzip dee.zip && cd devlmer-ecosystem-engine-main && bash install.sh "${p}"`;
    }

    navigator.clipboard.writeText(cmd).then(() => {
        // Animate the button
        const btn = document.getElementById('wizardBtnNext');
        const termBtn = document.getElementById('terminalCopyBtn');

        btn.classList.add('copied');
        btn.innerHTML = '<i class="fas fa-check"></i> Copiado al portapapeles';
        termBtn.classList.add('copied');
        termBtn.innerHTML = '<i class="fas fa-check"></i> Copiado';

        setTimeout(() => {
            btn.classList.remove('copied');
            btn.innerHTML = '<i class="fas fa-copy"></i> Copiar comando completo';
            termBtn.classList.remove('copied');
            termBtn.innerHTML = '<i class="fas fa-copy"></i> Copiar';
        }, 2500);
    });
}