<script setup>
import { ref, computed } from "vue";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { Head } from "@inertiajs/vue3";
import {
    UserIcon,
    MessageSquareIcon,
    CheckSquareIcon,
    LogOutIcon,
    LayoutDashboardIcon,
    PieChartIcon,
    CalendarIcon,
    SettingsIcon,
    EditIcon,
    TrashIcon,
    PlusIcon,
    EyeIcon,
} from "lucide-vue-next";

// users data (this would typically come from an API)
defineProps(['current_user']);


const user = ref({
    avatar: "/images/image.png",
    role: "Admin",
});

const functionalities = ref([
    { id: "overview", name: "View", icon: EyeIcon, component: () => ({}) },
]);

if (user.value.role === "Admin") {
    functionalities.value.push(
        { id: "insert", name: "Add", icon: PlusIcon, component: () => ({}) },
        { id: "edit", name: "Edit", icon: EditIcon, component: () => ({}) },
        { id: "delete", name: "Delete", icon: TrashIcon, component: () => ({}) }
    );
}

const selectedFunctionality = ref("overview");

const selectFunctionality = (id) => {
    selectedFunctionality.value = id;
};

const currentFunctionalityComponent = computed(() => {
    return (
        functionalities.value.find((f) => f.id === selectedFunctionality.value)
            ?.component || null
    );
});

const showAddUserModal = ref(false);
const editingUser = ref(null);
const userForm = ref({
    name: "",
    email: "",
    role: "Admin",
});

// Function to show the Add User modal
const showAddUser = () => {
    userForm.value = { name: "", email: "", role: "Admin" }; // Reset form for new user
    showAddUserModal.value = true;
};

// Function to show the Edit User modal, but only allow editing the role
const editUser = (userToEdit) => {
    userForm.value = {
        id: userToEdit.id, // Keep track of the user's ID
        name: userToEdit.name,
        email: userToEdit.email,
        role: userToEdit.role,
    };
    editingUser.value = userToEdit; // Store the selected user
    showAddUserModal.value = true; // Show the modal
};

// Function to submit the user (Add or Update), but only update the role
const submitUser = () => {
    if (editingUser.value) {
        // Update existing user
        const index = current_user.findIndex((u) => u.id === userForm.value.id);
        if (index !== -1) {
            current_user[index] = { ...current_user[index], ...userForm.value };
        }
    } else {
        // Add a new user
        const newUser = { ...userForm.value, id: Date.now() }; // Generate a unique ID
        current_user.push(newUser);
    }
    closeModal();
};


// Function to delete user
const deleteUser = (userId) => {
    users.value = users.value.filter((user) => user.id !== userId);
};

// Function to close the modal
const closeModal = () => {
    showAddUserModal.value = false;
    editingUser.value = null;
    userForm.value = { name: "", email: "", role: "User" }; // Reset the form
};

</script>

<template>
    <Head title="Dashboard" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="text-xl font-semibold leading-tight text-gray-800">
                Library Management
            </h2>
        </template>

        <div class="flex flex-col lg:flex-row h-full lg:h-screen bg-gray-100">
            <!-- Sidebar -->
            <aside
                class="w-full lg:w-1/4 bg-gray-200 p-4 lg:p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black"
            >
                <div class="flex flex-col items-center mb-6">
                    <img
                        :src="user.avatar"
                        :alt="user.name"
                        class="w-20 h-20 lg:w-24 lg:h-24 rounded-full border-2 border-black mb-2"
                    />
                    <div class="text-center">
                        <h2 class="text-lg lg:text-2xl font-bold text-gray-800">
                            {{ $page.props.auth.user.name }}
                        </h2>
                        <p class="text-sm lg:text-base text-gray-600">
                            {{ $page.props.auth.user.email }}
                        </p>
                        <p class="text-sm lg:text-base text-gray-500">
                            {{ user.role }}
                        </p>
                    </div>
                </div>
            </aside>

            <!-- Main Content -->
            <main class="w-full lg:w-3/4 p-4 lg:p-8">
                <h1
                    class="text-xl lg:text-3xl font-bold mb-4 lg:mb-6 text-gray-800 flex items-center"
                >
                    <LayoutDashboardIcon class="w-5 lg:w-8 h-5 lg:h-8 mr-2" />
                    Dashboard
                </h1>

                <!-- User Management -->
                <div class="bg-white shadow-md rounded-lg overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th
                                        class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                                    >
                                        Name
                                    </th>
                                    <th
                                        class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                                    >
                                        Email
                                    </th>
                                    <th
                                        class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                                    >
                                        Role
                                    </th>
                                    <th
                                        class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                                    >
                                        Actions
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <tr v-for="user in current_user" :key="user.id">
                                    <td
                                        class="px-4 lg:px-6 py-3 whitespace-nowrap"
                                    >
                                        {{ user.name }}
                                    </td>
                                    <td
                                        class="px-4 lg:px-6 py-3 whitespace-nowrap"
                                    >
                                        {{ user.email }}
                                    </td>
                                    <td
                                        class="px-4 lg:px-6 py-3 whitespace-nowrap"
                                    >
                                        {{ user.user_type }}
                                    </td>
                                    <td
                                        class="px-4 lg:px-6 py-3 whitespace-nowrap space-x-2"
                                    >
                                        <button
                                            @click="editUser(user)"
                                            class="text-indigo-600 hover:text-indigo-900"
                                        >
                                            Edit
                                        </button>
                                        <button
                                            @click="deleteUser(user.id)"
                                            class="text-red-600 hover:text-red-900"
                                        >
                                            Delete
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>

        <!-- Add/Edit User Modal -->
        <div
            v-if="showAddUserModal"
            class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center p-4 sm:p-8"
        >
            <div
                class="bg-white p-6 sm:p-8 rounded-lg shadow-xl max-w-md w-full"
            >
                <h3 class="text-lg sm:text-xl font-semibold mb-4">
                    {{ editingUser ? "Edit User" : "Add New User" }}
                </h3>
                <form @submit.prevent="submitUser" class="space-y-4">
                    <div>
                        <label
                            for="name"
                            class="block text-sm font-medium text-gray-700"
                            >Name</label
                        >
                        <input
                            type="text"
                            id="name"
                            v-model="userForm.name"
                            :disabled="!!editingUser"
                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm bg-gray-100"
                        />
                    </div>
                    <div>
                        <label
                            for="email"
                            class="block text-sm font-medium text-gray-700"
                            >Email</label
                        >
                        <input
                            type="email"
                            id="email"
                            v-model="userForm.email"
                            :disabled="!!editingUser"
                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm bg-gray-100"
                        />
                    </div>
                    <div>
                        <label
                            for="role"
                            class="block text-sm font-medium text-gray-700"
                            >Role</label
                        >
                        <select
                            id="role"
                            v-model="userForm.role"
                            required
                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring-indigo-200"
                        >
                            <option value="Admin">Admin</option>
                            <option value="Librarian">Editor</option>
                            <option value="User">User</option>
                            <!-- User option added -->
                        </select>
                    </div>
                    <div class="flex justify-between items-center mt-4">
                        <button
                            @click="closeModal"
                            type="button"
                            class="text-gray-500 hover:text-gray-800"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            class="bg-indigo-600 text-white hover:bg-indigo-700 px-4 py-2 rounded-lg"
                        >
                            Submit
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
