<script setup>
import { Head, Link } from "@inertiajs/vue3";

defineProps({
  canLogin: {
    type: Boolean,
  },
  canRegister: {
    type: Boolean,
  },
  laravelVersion: {
    type: String,
    required: true,
  },
  phpVersion: {
    type: String,
    required: true,
  },
});

function handleImageError() {
  document.getElementById("screenshot-container")?.classList.add("!hidden");
  document.getElementById("docs-card")?.classList.add("!row-span-1");
  document.getElementById("docs-card-content")?.classList.add("!flex-row");
  document.getElementById("background")?.classList.add("!hidden");
}
</script>

<template>
  <Head title="Welcome" />
  <div
    class="bg-[#F1F0E8] text-[#89A8B2] dark:bg-[#89A8B2] dark:text-[#F1F0E8]"
  >
    <img id="background" class="absolute -left-20 top-0 max-w-[877px]" src="" />
    <div
      class="relative flex min-h-screen flex-col items-center justify-center selection:bg-[#B3C8CF] selection:text-[#89A8B2]"
    >
      <div class="relative w-full max-w-2xl px-6 lg:max-w-7xl">
        <header
          class="grid grid-cols-2 items-center gap-2 py-10 lg:grid-cols-3"
        >
          <div class="flex lg:col-start-2 lg:justify-center">
            <svg
              width="62px"
              height="64px"
              viewBox="0 0 62 64"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
            >
              <path
                d="M31 8C29.5 6 25 2 13 2C12.8 2 12.5 2.2 12.5 2.5V29.5C12.5 29.8 12.8 30 13 30C25 30 29.5 34 31 36M31 8C32.5 6 37 2 49 2C49.2 2 49.5 2.2 49.5 2.5V29.5C49.5 29.8 49.2 30 49 30C37 30 32.5 34 31 36M31 8V36"
                stroke="#000000"
                stroke-width="1.5"
                stroke-linejoin="round"
                fill="none"
              />
              <path
                d="M56.2353 10H60C60.2761 10 60.5 10.2239 60.5 10.5V52.5C60.5 53 60 53.2 59.6 53C57 51.5 52.6 50 46.5882 50C40 50 35 53 31 55C27 53 22 50 15.4118 50C9.4 50 5 51.5 2.4 53C2 53.2 1.5 53 1.5 52.5V10.5C1.5 10.2239 1.72386 10 2 10H5.76471"
                stroke="#000000"
                stroke-width="1.5"
                stroke-linejoin="round"
                fill="none"
              />
            </svg>
          </div>
          <nav
            v-if="canLogin"
            class="flex flex-1 justify-end items-center space-x-4"
          >
            <Link
              v-if="$page.props.auth.user"
              :href="route('dashboard')"
              class="rounded-md px-4 py-2 bg-[#000000] text-[#FFFFFF] font-medium ring-1 ring-transparent transition-all duration-300 hover:bg-[#C0C0C0] hover:text-[#2F4F4F] focus:outline-none focus-visible:ring-[#89A8B2] dark:bg-[#B3C8CF] dark:text-[#F1F0E8] dark:hover:bg-[#E5E1DA] dark:hover:text-[#89A8B2] dark:focus-visible:ring-[#F1F0E8]"
            >
              Dashboard
            </Link>

            <template v-else>
              <Link
                :href="route('login')"
                class="rounded-md px-4 py-2 bg-[#FFFFFF] text-[#000000] font-medium ring-1 ring-transparent transition-all duration-300 hover:bg-[#C0C0C0] hover:text-[#2F4F4F] focus:outline-none focus-visible:ring-[#89A8B2] dark:bg-[#B3C8CF] dark:text-[#F1F0E8] dark:hover:bg-[#E5E1DA] dark:hover:text-[#89A8B2] dark:focus-visible:ring-[#F1F0E8]"
              >
                Log in
              </Link>

              <Link
                v-if="canRegister"
                :href="route('register')"
                class="rounded-md px-4 py-2 bg-[#000000] text-[#FFFFFF] font-medium ring-1 ring-transparent transition-all duration-300 hover:bg-[#C0C0C0] hover:text-[#2F4F4F] focus:outline-none focus-visible:ring-[#89A8B2] dark:bg-[#B3C8CF] dark:hover:bg-[#89A8B2]"
              >
                Register
              </Link>
            </template>
          </nav>
        </header>

        <main class="mt-6">
          <!-- Hero Section -->
          <div
            class="relative overflow-hidden rounded-lg bg-gradient-to-r from-[#89A8B2] to-[#B3C8CF] p-8 shadow-xl"
          >
            <div
              class="relative z-10 flex flex-col-reverse items-center gap-8 lg:flex-row lg:justify-between"
            >
              <!-- Text Content -->
              <div class="text-center lg:text-left">
                <h1 class="mb-4 text-4xl font-bold text-[#F1F0E8] lg:text-6xl">
                  Manage Your Books with Ease
                </h1>
                <p class="mb-6 text-lg text-[#E5E1DA]">
                  Organize, track, and discover your reading journey with our
                  intuitive book management system
                </p>
                <div
                  class="flex flex-col gap-4 sm:flex-row sm:justify-center lg:justify-start"
                >
                  <Link
                    v-if="canRegister"
                    :href="route('register')"
                    class="rounded-full bg-[#F1F0E8] px-6 py-3 font-semibold text-[#89A8B2] shadow-lg transition hover:bg-[#E5E1DA]"
                  >
                    Get Started
                  </Link>
                  <button
                    class="rounded-full border-2 border-[#F1F0E8] px-6 py-3 font-semibold text-[#F1F0E8] transition hover:bg-[#F1F0E8] hover:text-[#89A8B2]"
                  >
                    Learn More
                  </button>
                </div>
              </div>
              <!-- Hero Image -->
              <div class="w-full max-w-md lg:w-1/2">
                <img
                  src="/images/landing.png"
                  alt="Book Management Illustration"
                  class="w-full"
                />
              </div>
            </div>
          </div>

          <!-- Features Section -->
          <div class="mt-16 grid gap-8 md:grid-cols-3">
            <div
              class="rounded-lg bg-[#F1F0E8] p-6 shadow-lg dark:bg-[#89A8B2]"
            >
              <div
                class="mb-4 rounded-full bg-[#FFFFFF] p-3 w-12 h-12 flex items-center justify-center dark:bg-[#E5E1DA]"
              >
                <svg
                  class="h-6 w-6 text-[#89A8B2] dark:text-[#89A8B2]"
                  fill="none"
                  stroke="black"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                  />
                </svg>
              </div>
              <h3
                class="mb-2 text-xl font-semibold text-[#000000] dark:text-[#F1F0E8]"
              >
                Easy Organization
              </h3>
              <p class="text-[#000000] dark:text-[#E5E1DA]">
                Categorize and organize your books with our intuitive interface
              </p>
            </div>

            <div
              class="rounded-lg bg-[#F1F0E8] p-6 shadow-lg dark:bg-[#89A8B2]"
            >
              <div
                class="mb-4 rounded-full bg-[#FFFFFF] p-3 w-12 h-12 flex items-center justify-center dark:bg-[#E5E1DA]"
              >
                <svg
                  class="h-6 w-6 text-[#89A8B2] dark:text-[#89A8B2]"
                  fill="none"
                  stroke="black"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 7h18M3 12h18M3 17h18"
                  />
                </svg>
              </div>
              <h3
                class="mb-2 text-xl font-semibold text-[#000000] dark:text-[#F1F0E8]"
              >
                Track Progress
              </h3>
              <p class="text-[#000000] dark:text-[#E5E1DA]">
                Monitor your reading progress and set reading goals
              </p>
            </div>

            <div
              class="rounded-lg bg-[#F1F0E8] p-6 shadow-lg dark:bg-[#89A8B2]"
            >
              <div
                class="mb-4 rounded-full bg-[#FFFFFF] p-3 w-12 h-12 flex items-center justify-center dark:bg-[#E5E1DA]"
              >
                <svg
                  class="h-6 w-6 text-[#89A8B2] dark:text-[#89A8B2]"
                  fill="none"
                  stroke="black"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  />
                </svg>
              </div>
              <h3
                class="mb-2 text-xl font-semibold text-[#000000] dark:text-[#F1F0E8]"
              >
                Quick Access
              </h3>
              <p class="text-[#000000] dark:text-[#E5E1DA]">
                Access your library anytime, anywhere with cloud sync
              </p>
            </div>
          </div>
        </main>

        <footer class="text-black py-16">
          <div class="text-center">
            <p class="text-sm">
              Library Management System ©
              {{ new Date().getFullYear() }}
            </p>
          </div>
        </footer>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Webkit Browsers */
::-webkit-scrollbar {
  width: 12px;
  height: 12px; /* for horizontal scrollbars */
}

.textsy textarea {
  resize: none;
}

::-webkit-scrollbar-track {
  background: #f1f0e8;
  border-radius: 50px;
}

::-webkit-scrollbar-thumb {
  background-color: #89a8b2;
  border-radius: 50px; /* Circular border */
  border: 3px solid #f1f0e8; /* Adds space around thumb */
}

::-webkit-scrollbar-thumb:hover {
  background-color: #b3c8cf;
}
</style>