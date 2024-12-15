<script setup>
import GuestLayout from "@/Layouts/GuestLayout.vue";
import InputError from "@/Components/InputError.vue";
import InputLabel from "@/Components/InputLabel.vue";
import PrimaryButton from "@/Components/PrimaryButton.vue";
import TextInput from "@/Components/TextInput.vue";
import { Head, Link, useForm } from "@inertiajs/vue3";
import { Mail, User, Lock , EyeClosed } from "lucide-vue-next";
import DOMPurify from 'dompurify';


const sanitizeInput = (value) => DOMPurify.sanitize(value);

const rules = {
    required: (v) => !!v || 'This field is required.',
    name: (v) => (v && v.length >= 5 && v.length <= 50) || 'Name must be 10-50 characters long.',
    email: (v) =>
        /^(?:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$/.test(v) || 'E-mail must be valid.',
    password: (v) =>
        (v &&
            v.length >= 8 &&
            /[A-Z]/.test(v) &&
            /[a-z]/.test(v) &&
            /[0-9]/.test(v) &&
            /[!@#$%^&*(),.?":{}|<>]/.test(v)) ||
        'Password must be at least 8 characters, including uppercase, lowercase, number, and special character.',
};

const form = useForm({
    name: "",
    email: "",
    password: "",
    password_confirmation: "",
});

const submit = () => {
    const errors = {};

    // Sanitize the inputs
    const sanitizedName = sanitizeInput(form.name);
    const sanitizedEmail = sanitizeInput(form.email);
    const sanitizedPassword = sanitizeInput(form.password);
    const sanitizedPasswordConfirmation = sanitizeInput(form.password_confirmation);

    // Name validation
    if (!rules.required(sanitizedName)) {
        errors.name = "Name should be at least 5 characters long";
    }

    // Email validation
    if (!rules.email(sanitizedEmail)) {
        errors.email = "E-mail must be valid";
    }

    // Password validation
    if (!rules.password(sanitizedPassword)) {
        errors.password =
            "Password must be at least 8 characters and contain uppercase, lowercase, number, and special character";
    }

    // Password confirmation validation
    if (sanitizedPassword !== sanitizedPasswordConfirmation) {
        errors.password_confirmation = "Password confirmation does not match";
    }

    // Assign errors to form
    form.errors = errors;

    // Stop submission if there are any errors
    if (Object.keys(errors).length > 0) {
        return;
    }

    // Submit the form if validation passes
    form.post(route('register'), {
        onFinish: () => form.reset('password', 'password_confirmation'),
    });
};
</script>

<template>
    <GuestLayout>
        <Head title="Register" />

        <form @submit.prevent="submit">
            <h1 class="text-center text-3xl font-bold py-4">
                Welcome To Bookkeeper
            </h1>
            <h4 class="text-1xl pt-6 pb-2">Please fill up the following:</h4>

            <div>
                <InputLabel for="name" value="Name" />
                <div class="relative">
                    <TextInput
                        id="name"
                        type="text"
                        class="mt-1 block w-full pl-10"
                        v-model="form.name"
                        maxlength="50"
                        required
                        autofocus
                        autocomplete="name"
                    />
                    <User
                        class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                    />
                </div>
                <InputError class="mt-2" :message="form.errors.name" />
            </div>

            <div class="mt-4">
                <InputLabel for="email" value="Email" />
                <div class="relative">
                    <TextInput
                        id="email"
                        type="email"
                        class="mt-1 block w-full pl-10"
                        v-model="form.email"
                        maxlength="100"
                        required
                        autocomplete="username"
                    />
                    <Mail
                        class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                    />
                </div>
                <InputError class="mt-2" :message="form.errors.email" />
            </div>

            <div class="mt-4">
                <InputLabel for="password" value="Password" />
                <div class="relative">
                    <TextInput
                        id="password"
                        type="password"
                        class="mt-1 block w-full pl-10"
                        v-model="form.password"
                        maxlength="50"
                        required
                        autocomplete="new-password"
                    />
                    <Lock
                        class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                    />
                </div>
                <InputError class="mt-2" :message="form.errors.password" />
            </div>

            <div class="mt-4">
                <InputLabel
                    for="password_confirmation"
                    value="Confirm Password"
                />
                <div class="relative">
                    <TextInput
                        id="password_confirmation"
                        type="password"
                        class="mt-1 block w-full pl-10"
                        v-model="form.password_confirmation"
                        maxlength="50"
                        required
                        autocomplete="new-password"
                    />
                    <Lock
                        class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
                    />
                </div>
                <InputError
                    class="mt-2"
                    :message="form.errors.password_confirmation"
                />
            </div>

            <div class="mt-4 flex items-center justify-end">
                <Link
                    :href="route('login')"
                    class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                >
                    Already registered?
                </Link>

                <PrimaryButton
                    class="ms-4"
                    :class="{ 'opacity-25': form.processing }"
                    :disabled="form.processing"
                >
                    Register
                </PrimaryButton>
            </div>
        </form>
    </GuestLayout>
</template>