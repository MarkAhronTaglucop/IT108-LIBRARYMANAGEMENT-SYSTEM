<script setup>
import { ref, computed } from "vue";
import AuthenticatedLayout from "@/Layouts/AuthenticatedLayout.vue";
import { Head, router } from "@inertiajs/vue3";
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
  Book as LucideBookIcon,
  RefreshCcw,
} from "lucide-vue-next";

// Props
const props = defineProps({
  users: Array,
  roles: Array,
  summary: {
    type: Object,
    required: true,
  },
  logs: Array,
});

// Reactive state for users
const users = ref([...props.users]);

// To get the role based on user id
const getRole = (roleId) => {
  const role = props.roles.find((role) => role.id === roleId);
  return role ? role.user_type : "Unknown";
};

// User profile state
const user = ref({
  avatar: "/images/image.png",
});

// User Form for Editing Role
const showAddUserModal = ref(false);
const editingUser = ref(null);
const userForm = ref({
  name: "",
  email: "",
  role: "",
});

// Function to delete user
const deleteUser = (userId) => {
  if (confirm("Are you sure you want to delete this user?")) {
    router.delete(route("admin.deleteUser", { user: userId }), {
      onSuccess: () => {
        users.value = users.value.filter((user) => user.id !== userId);
        alert("User deleted successfully.");
      },
      onError: () => {
        alert("There was an error deleting the user.");
      },
    });
  }
};

// Function to show the Edit User modal
// Open the modal and populate the form for editing
const editUser = (user) => {
  if (getRole(user.role_id) === "admin") {
    alert("Admin roles cannot be edited or demoted.");
    return;
  }

  showAddUserModal.value = true;
  editingUser.value = user;
  userForm.value = {
    id: user.id,
    name: user.name,
    email: user.email,
    role_id: user.role_id,
  };
};

// Submit updated role to the backend
const submitUser = () => {
  if (editingUser.value) {
    // Prevent demotion of an Admin
    if (
      getRole(editingUser.value.role_id) === "admin" &&
      userForm.value.role_id !== editingUser.value.role_id
    ) {
      alert("Once promoted to Admin, users cannot be demoted.");
      return;
    }

    // Proceed with the update if conditions are met
    router.put(
      route("admin.updateUserRole", { user: userForm.value.id }),
      {
        role_id: userForm.value.role_id,
      },
      {
        onSuccess: () => {
          const userIndex = users.value.findIndex(
            (u) => u.id === userForm.value.id
          );
          if (userIndex > -1) {
            users.value[userIndex].role_id = userForm.value.role_id;
          }
          closeModal();
          alert("User role updated successfully!");
        },
        onError: () => {
          alert("There was an error updating the user role.");
        },
      }
    );
  } else {
    alert("No user selected for editing.");
  }
};

// Function to refresh the materialized view
const refreshView = async () => {
  try {
    // Send POST request via Inertia
    router.post(route("admin.refresh"));
  } catch (err) {
    // Handle error response
    error.value = "Failed to refresh the materialized view.";
    console.error(err);
  }
};

// Close the modal and reset the form
const closeModal = () => {
  showAddUserModal.value = false;
  editingUser.value = null;
  userForm.value = { id: null, name: "", email: "", role_id: "" };
};
</script>


<template>
  <Head title="Dashboard" />

  <AuthenticatedLayout>
    <header class="bg-[#E5E1DA] shadow p-4 lg:p-6 border-b border-black">
      <div class="flex justify-between items-center">
        <h2
          class="text-xl font-semibold leading-tight text-gray-800 flex items-center"
        >
          <!-- Book Icon from Lucide -->
          <LucideBookIcon class="w-15 h-15 mr-2 text-gray-800" />
          <span>Library Management</span>
        </h2>
      </div>
    </header>

    <div class="flex flex-col lg:flex-row h-full lg:h-screen bg-gray-100">
      <!-- Sidebar -->
      <aside
        class="w-full lg:w-1/4 bg-[#E5E1DA] p-4 lg:p-6 flex flex-col border-b lg:border-b-0 lg:border-r border-black"
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
            <p class="font-bold text-sm lg:text-base text-gray-500">
              {{ getRole($page.props.auth.user.role_id) }}
            </p>
          </div>
        </div>
      </aside>

      <!-- Main Content -->
      <main
        class="w-full lg:w-3/4 p-4 lg:p-8 bg-[#F1F0E8] min-h-100 overflow-y-auto"
      >
        <h1
          class="text-xl lg:text-3xl font-bold mb-4 lg:mb-6 text-gray-800 flex items-center"
        >
          <LayoutDashboardIcon class="w-5 lg:w-8 h-5 lg:h-8 mr-2" />
          Dashboard
        </h1>

        <!-- Total Users and Librarians -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
          <!-- Total Users -->
          <div class="bg-white shadow rounded-lg p-4 flex items-center transition duration-300 ease-in-out transform hover:scale-105">
            <UserIcon
              class="w-10 h-10 text-purple-500 mr-3 bg-purple-100 rounded-full p-2"
            />
            <div>
              <h2 class="text-lg font-bold">Total Users</h2>
              <p class="text-2xl">{{ summary.total_users }}</p>
            </div>
          </div>
          <!-- Total Librarians -->
          <div class="bg-white shadow rounded-lg p-4 flex items-center transition duration-300 ease-in-out transform hover:scale-105">
            <MessageSquareIcon
              class="w-10 h-10 text-green-500 mr-3 bg-green-100 rounded-full p-2"
            />
            <div>
              <h2 class="text-lg font-bold">Total Librarians</h2>
              <p class="text-2xl">{{ summary.total_librarians_role_2 }}</p>
            </div>
          </div>
        </div>

        <!-- User Management -->
        <div
          class="bg-white shadow-md rounded-lg min-h-80 max-h-80 overflow-y-auto"
        >
          <h2 class="text-lg font-semibold mb-4 pt-2 px-7">User Management</h2>
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
                <tr v-for="userviews in users" :key="userviews.id">
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ userviews.name }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ userviews.email }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ getRole(userviews.role_id) }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap space-x-3">
                    <button
                      v-if="getRole(userviews.role_id) !== 'admin'"
                      @click="editUser(userviews)"
                      class="text-indigo-600 hover:text-indigo-900"
                    >
                      Edit
                    </button>
                    <span
                      v-else
                      class="text-gray-500 cursor-not-allowed"
                      title="Admins cannot be deleted"
                    >
                      Edit
                    </span>
                    <button
                      v-if="getRole(userviews.role_id) !== 'admin'"
                      @click="deleteUser(userviews.id)"
                      class="text-red-600 hover:text-red-900"
                    >
                      Delete
                    </button>
                    <span
                      v-else
                      class="text-gray-500 cursor-not-allowed"
                      title="Admins cannot be deleted"
                    >
                      Delete
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Refresh Button For Activity Logs -->
        <div class="flex justify-end pt-4">
          <button
            @click="refreshView"
            class="px-4 py-2 bg-black text-white rounded hover:bg-green-700 transition flex items-center"
          >
            <RefreshCcw class="w-5 h-5 mr-2" />
            Refresh
          </button>
        </div>
        <!-- Activity  Logs -->
        <div
          class="bg-white shadow-md rounded-lg min-h-80 max-h-80 overflow-y-auto mt-4"
        >
          <h2 class="text-lg font-semibold mb-4 py-2 px-7">Activity Logs</h2>

          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th
                    class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                  >
                    Id
                  </th>
                  <th
                    class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                  >
                    Username
                  </th>
                  <th
                    class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                  >
                    Table Name
                  </th>
                  <th
                    class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                  >
                    Action
                  </th>
                  <th
                    class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                  >
                    Time
                  </th>
                  <th
                    class="px-4 lg:px-6 py-2 lg:py-3 text-left text-xs lg:text-sm font-medium text-gray-500 uppercase tracking-wider"
                  >
                    Role
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200 text-black">
                <tr v-for="log in logs" :key="log.users_id">
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ log.users_id }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ log.username }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ log.table_name }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ log.action }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ log.time }}
                  </td>
                  <td class="px-4 lg:px-6 py-3 whitespace-nowrap">
                    {{ log.role }}
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
      <div class="bg-white p-6 sm:p-8 rounded-lg shadow-xl max-w-md w-full">
        <h3 class="text-lg sm:text-xl font-semibold mb-4">
          {{ editingUser ? "Edit User" : "Add New User" }}
        </h3>
        <form @submit.prevent="submitUser" class="space-y-4">
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700"
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
            <label for="email" class="block text-sm font-medium text-gray-700"
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
            <label for="role" class="block text-sm font-medium text-gray-700"
              >Role</label
            >
            <select
              id="role"
              v-model="userForm.role_id"
              required
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring-indigo-200"
            >
              <option
                v-for="role in props.roles"
                :key="role.id"
                :value="role.id"
              >
                {{ role.user_type }}
              </option>
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
  background: #f1f1f1;
  border-radius: 50px;
}

::-webkit-scrollbar-thumb {
  background-color: #888;
  border-radius: 50px; /* Circular border */
  border: 3px solid #f1f1f1; /* Adds space around thumb */
}

::-webkit-scrollbar-thumb:hover {
  background-color: #555;
}
</style>
