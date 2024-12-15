<script setup>
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { Head } from "@inertiajs/vue3";
import {
    BookOpen,
    Search,
    Users,
    BookMarked,
    Clock,
    TrendingUp,
    Calendar,
    Bell,
    Settings,
    LogOut,
    LayoutDashboardIcon,
    ChevronLeft,
    ChevronRight,
} from "lucide-vue-next";
import BookCard from "@/Components/BookCard.vue";
import { ref, computed, onMounted, onUnmounted } from "vue";

const props = defineProps({
    summary: {
        type: Object,
        required: true,
    },
});

const notifications = ref([
    {
        id: 1,
        message: "New book added: 'The Midnight Library'",
        time: "2 hours ago",
    },
    {
        id: 2,
        message: "Overdue book: 'To Kill a Mockingbird'",
        time: "1 day ago",
    },
]);

const popularGenres = ref([
    { name: "Fiction", percentage: 40 },
    { name: "Non-Fiction", percentage: 30 },
    { name: "Science", percentage: 15 },
    { name: "History", percentage: 10 },
    { name: "Others", percentage: 5 },
]);

const recentActivities = ref([
    {
        action: "Borrowed",
        book: "The Great Gatsby",
        user: "John Doe",
        time: "3 hours ago",
    },
    { action: "Returned", book: "1984", user: "Jane Smith", time: "1 day ago" },
    {
        action: "Reserved",
        book: "To Kill a Mockingbird",
        user: "Alice Johnson",
        time: "2 days ago",
    },
]);

const currentIndex = ref(0);

const books = [
    {
        title: "Sapiens: A Brief History of Humankind",
        author: "Yuval Noah Harari",
        category: "Non-Fiction, Anthropology",
        year: "2011",
        imageUrl: "https://covers.openlibrary.org/b/id/7064681-L.jpg",
    },
    {
        title: "Educated",
        author: "Tara Westover",
        category: "Non-Fiction, Memoir",
        year: "2018",
        imageUrl: "https://covers.openlibrary.org/b/id/3703054-L.jpg",
    },
    {
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        category: "Fiction, Tragedy",
        year: "1925",
        imageUrl: "https://covers.openlibrary.org/b/id/5302910-L.jpg",
    },
    {
        title: "The Lord of the Rings",
        author: "J.R.R. Tolkien",
        category: "Fiction, Fantasy",
        year: "1954",
        imageUrl: "https://covers.openlibrary.org/b/id/7222246-L.jpg",
    },
    {
        title: "Atomic Habits",
        author: "James Clear",
        category: "Non-Fiction, Self-Help",
        year: "2018",
        imageUrl: "https://covers.openlibrary.org/b/id/9362102-L.jpg",
    },
    {
        title: "Dune",
        author: "Frank Herbert",
        category: "Fiction, Science Fiction",
        year: "1965",
        imageUrl: "https://covers.openlibrary.org/b/id/8214816-L.jpg",
    },
    {
        title: "Pride and Prejudice",
        author: "Jane Austen",
        category: "Fiction, Romance",
        year: "1813",
        imageUrl: "https://covers.openlibrary.org/b/id/8221860-L.jpg",
    },
    {
        title: "1984",
        author: "George Orwell",
        category: "Fiction, Dystopian",
        year: "1949",
        imageUrl: "https://covers.openlibrary.org/b/id/7222240-L.jpg",
    },
    {
        title: "The Catcher in the Rye",
        author: "J.D. Salinger",
        category: "Fiction, Coming-of-Age",
        year: "1951",
        imageUrl: "https://covers.openlibrary.org/b/id/8228781-L.jpg",
    },
    {
        title: "Becoming",
        author: "Michelle Obama",
        category: "Non-Fiction, Memoir",
        year: "2018",
        imageUrl: "https://covers.openlibrary.org/b/id/9351362-L.jpg",
    },
];

const visibleBooks = computed(() => {
    const start = currentIndex.value;
    return books.slice(start, start + 3);
});

function nextSlide() {
    if (currentIndex.value < books.length - 3) {
        currentIndex.value++;
    } else {
        currentIndex.value = 0;
    }
}

function prevSlide() {
    if (currentIndex.value > 0) {
        currentIndex.value--;
    } else {
        currentIndex.value = books.length - 3;
    }
}

let autoSlideInterval;

function startAutoSlide() {
    autoSlideInterval = setInterval(() => {
        nextSlide();
    }, 5000); // Change slide every 5 seconds
}

function stopAutoSlide() {
    clearInterval(autoSlideInterval);
}

onMounted(() => {
    startAutoSlide();
});

onUnmounted(() => {
    stopAutoSlide();
});
</script>

<template>
    <Head title="Library Dashboard" />

    <AuthenticatedLayout>
        <div class="min-h-screen bg-custom">
            <div class="flex-1 p-8 overflow-auto">
                <header class="flex justify-between items-center mb-8">
                    <div
                        class="flex items-center space-x-2 inline-flex bg-white bg-opacity-90 p-4 rounded-lg"
                    >
                        <LayoutDashboardIcon class="w-8 h-8 text-black" />
                        <h2 class="text-2xl font-bold text-black">Dashboard</h2>
                    </div>
                </header>

                <section
                    class="bg-transparent bg-opacity-85 rounded-lg shadow-md p-6 mb-4"
                >
                    <!-- Header -->
                    <div
                        class="flex justify-center items-center mb-6 transition duration-300 ease-in-out transform hover:scale-105"
                    >
                        <div
                            class="bg-white bg-opacity-90 rounded-lg px-4 py-2 flex items-center"
                        >
                            <TrendingUp class="w-8 h-8 mr-2 text-[#000000]" />
                            <h2 class="text-xl font-semibold text-black">
                                Most Read Books This Month
                            </h2>
                        </div>
                    </div>

                    <!-- Book Carousel -->
                    <div class="relative">
                        <div class="flex justify-between items-center">
                            <!-- Left Button -->
                            <button
                                @click="prevSlide"
                                @mouseenter="stopAutoSlide"
                                @mouseleave="startAutoSlide"
                                class="bg-[#000000] hover:bg-[#707070] text-white rounded-full p-2 focus:outline-none transition duration-300 ease-in-out transform hover:scale-110"
                            >
                                <ChevronLeft class="w-6 h-6" />
                            </button>

                            <!-- Books -->
                            <div
                                class="flex justify-center space-x-4 overflow-hidden"
                            >
                                <div
                                    v-for="book in visibleBooks"
                                    :key="book.title"
                                    class="transition-all duration-500 ease-in-out transform hover:scale-105"
                                >
                                    <BookCard v-bind="book" class="w-64" />
                                </div>
                            </div>

                            <!-- Right Button -->
                            <button
                                @click="nextSlide"
                                @mouseenter="stopAutoSlide"
                                @mouseleave="startAutoSlide"
                                class="bg-[#000000] hover:bg-[#707070] text-white rounded-full p-2 focus:outline-none transition duration-300 ease-in-out transform hover:scale-110"
                            >
                                <ChevronRight class="w-6 h-6" />
                            </button>
                        </div>
                    </div>
                </section>

                <section class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div
                        v-for="(item, index) in [
                            {
                                icon: BookOpen,
                                title: 'Total Books',
                                value: summary.total_books,
                                color: 'blue',
                            },
                            {
                                icon: BookMarked,
                                title: 'Books Borrowed',
                                value: summary.total_borrowed_books,
                                color: 'green',
                            },
                            {
                                icon: Users,
                                title: 'Active Users',
                                value: summary.total_users_role_1,
                                color: 'purple',
                            },
                        ]"
                        :key="index"
                        class="bg-white bg-opacity-90 rounded-lg shadow-md p-6 flex items-center space-x-4 transition duration-300 ease-in-out transform hover:scale-105"
                    >
                        <div :class="`bg-${item.color}-100 p-3 rounded-full`">
                            <component
                                :is="item.icon"
                                :class="`w-8 h-8 text-${item.color}-500`"
                            />
                        </div>
                        <div>
                            <h3 class="text-lg font-semibold text-gray-700">
                                {{ item.title }}
                            </h3>
                            <p class="text-2xl font-bold text-gray-900">
                                {{ item.value }}
                            </p>
                        </div>
                    </div>
                </section>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <section
                        class="bg-white bg-opacity-80 rounded-lg shadow-md p-6 transition duration-300 ease-in-out transform hover:scale-105"
                    >
                        <h2
                            class="text-2xl font-semibold text-gray-800 mb-6 flex items-center"
                        >
                            <BookOpen class="w-6 h-6 mr-2 text-[#000000]" />
                            Popular Genres
                        </h2>
                        <div class="space-y-4">
                            <div
                                v-for="genre in popularGenres"
                                :key="genre.name"
                                class="flex items-center"
                            >
                                <span class="w-24 text-sm text-gray-600">{{
                                    genre.name
                                }}</span>
                                <div
                                    class="flex-1 h-4 bg-gray-200 rounded-full overflow-hidden transition duration-300 ease-in-out transform hover:scale-105"
                                >
                                    <div
                                        class="h-full bg-[#000000] transition-all duration-500 ease-in-out"
                                        :style="{
                                            width: `${genre.percentage}%`,
                                        }"
                                    ></div>
                                </div>
                                <span
                                    class="w-12 text-sm text-gray-600 text-right"
                                    >{{ genre.percentage }}%</span
                                >
                            </div>
                        </div>
                    </section>

                    <section
                        class="bg-white bg-opacity-90 rounded-lg shadow-md p-6 transition duration-300 ease-in-out transform hover:scale-105"
                    >
                        <h2
                            class="text-2xl font-semibold text-gray-800 mb-6 flex items-center"
                        >
                            <Clock class="w-6 h-6 mr-2 text-[#89A8B2]" />
                            Recent Activities
                        </h2>
                        <ul class="space-y-4">
                            <li
                                v-for="activity in recentActivities"
                                :key="activity.book"
                                class="flex items-start space-x-3 transition duration-300 ease-in-out transform hover:scale-105"
                            >
                                <div
                                    :class="{
                                        'bg-green-100 text-green-800':
                                            activity.action === 'Borrowed',
                                        'bg-blue-100 text-blue-800':
                                            activity.action === 'Returned',
                                        'bg-yellow-100 text-yellow-800':
                                            activity.action === 'Reserved',
                                    }"
                                    class="px-2 py-1 rounded text-sm font-medium"
                                >
                                    {{ activity.action }}
                                </div>
                                <div class="flex-1">
                                    <p
                                        class="text-sm font-medium text-gray-900"
                                    >
                                        {{ activity.book }}
                                    </p>
                                    <p class="text-sm text-gray-500">
                                        {{ activity.user }}
                                    </p>
                                </div>
                                <span class="text-sm text-gray-400">{{
                                    activity.time
                                }}</span>
                            </li>
                        </ul>
                    </section>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.bg-custom {
    background-image: url("/images/bg_landing1.jpg");
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    min-height: 100vh;
    /* background: #ffffff; */
}
</style>
