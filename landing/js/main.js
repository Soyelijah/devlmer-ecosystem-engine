/**
 * Devlmer Ecosystem Engine - Main Scripts
 * Scroll reveals, clipboard, navigation, counters
 */

// ==================== INTERSECTION OBSERVER FOR SCROLL REVEALS ====================
const observerOptions = {
    threshold: 0.05,
    rootMargin: '50px 0px 0px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

const revealElements = document.querySelectorAll('.reveal');
revealElements.forEach(el => observer.observe(el));

// Fallback: forzar visibilidad después de 2.5s para scroll rápido
setTimeout(() => {
    revealElements.forEach(el => el.classList.add('visible'));
}, 2500);

// ==================== COPY TO CLIPBOARD ====================
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        const btn = event.target.closest('.copy-btn');
        const originalText = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-check"></i> ¡Copiado!';
        setTimeout(() => {
            btn.innerHTML = originalText;
        }, 2000);
    });
}

// ==================== SCROLL TO SECTION ====================
function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
    }
}

// ==================== SMOOTH SCROLL FOR NAV LINKS ====================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ==================== NAVBAR HIDE ON SCROLL DOWN ====================
let lastScrollTop = 0;
const header = document.querySelector('header');

window.addEventListener('scroll', () => {
    let scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    if (scrollTop > 100) {
        header.style.borderBottomColor = 'rgba(0, 212, 170, 0.1)';
    } else {
        header.style.borderBottomColor = 'rgba(255, 255, 255, 0.05)';
    }
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
});

// ==================== ANIMATED COUNTER ====================
const stats = document.querySelectorAll('.stat-number');
const counterObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const element = entry.target;
            const text = element.textContent;
            const number = parseInt(text.match(/\d+/)[0]);
            const duration = 2000;
            const steps = 60;
            const stepValue = number / steps;
            let current = 0;
            const timer = setInterval(() => {
                current += stepValue;
                if (current >= number) {
                    element.textContent = text;
                    clearInterval(timer);
                    counterObserver.unobserve(element);
                } else {
                    element.textContent = Math.floor(current) + text.replace(/\d+/, '');
                }
            }, duration / steps);
        }
    });
}, observerOptions);

stats.forEach(stat => counterObserver.observe(stat));