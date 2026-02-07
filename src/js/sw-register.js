// Service Worker Registration

if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker
            .register('./sw.js')
            .then(registration => {
                console.log('ServiceWorker registered:', registration.scope);

                // Check for updates periodically
                setInterval(() => {
                    registration.update();
                }, 60000); // Check every minute
            })
            .catch(error => {
                console.log('ServiceWorker registration failed:', error);
            });
    });
}

// PWA Install Prompt
let deferredPrompt;
const installButton = document.getElementById('installButton');

window.addEventListener('beforeinstallprompt', (e) => {
    // Prevent the mini-infobar from appearing on mobile
    e.preventDefault();
    // Stash the event so it can be triggered later
    deferredPrompt = e;
    // Show install button
    if (installButton) {
        installButton.classList.remove('hidden');
        installButton.classList.add('slide-in-down');
    }
});

if (installButton) {
    installButton.addEventListener('click', async () => {
        if (!deferredPrompt) {
            return;
        }

        // Show the install prompt
        deferredPrompt.prompt();

        // Wait for the user to respond to the prompt
        const { outcome } = await deferredPrompt.userChoice;

        console.log(`User response to the install prompt: ${outcome}`);

        // Clear the deferredPrompt so it can only be used once
        deferredPrompt = null;

        // Hide the install button
        installButton.classList.add('hidden');
    });
}

// Track installation
window.addEventListener('appinstalled', (event) => {
    console.log('PWA was installed successfully');
    if (installButton) {
        installButton.classList.add('hidden');
    }
});

// Handle iOS-specific installation
function isIOS() {
    return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
}

function isInStandaloneMode() {
    return ('standalone' in window.navigator) && (window.navigator.standalone);
}

// Show iOS install instructions if needed
if (isIOS() && !isInStandaloneMode() && installButton) {
    installButton.addEventListener('click', () => {
        const modal = document.createElement('div');
        modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4';
        modal.innerHTML = `
            <div class="bg-white rounded-lg p-6 max-w-md">
                <h3 class="text-xl font-bold text-dark-navy mb-4">
                    Instalar no iOS
                </h3>
                <div class="space-y-3 text-gray-700">
                    <p>Para instalar este app no seu iPhone/iPad:</p>
                    <ol class="list-decimal list-inside space-y-2 text-sm">
                        <li>Toque no botão de compartilhar (
                            <svg class="inline w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M16 5l-1.42 1.42-1.59-1.59V16h-1.98V4.83L9.42 6.42 8 5l4-4 4 4zm4 5v11c0 1.1-.9 2-2 2H6c-1.11 0-2-.9-2-2V10c0-1.11.89-2 2-2h3v2H6v11h12V10h-3V8h3c1.1 0 2 .89 2 2z"/>
                            </svg>
                        )</li>
                        <li>Role para baixo e toque em "Adicionar à Tela de Início"</li>
                        <li>Toque em "Adicionar"</li>
                    </ol>
                </div>
                <button onclick="this.closest('.fixed').remove()" class="mt-6 w-full bg-ocean-blue hover:bg-sky-blue text-white px-4 py-2 rounded-lg font-medium transition-colors duration-200">
                    Entendi
                </button>
            </div>
        `;
        document.body.appendChild(modal);
    });
}
