<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::get('/user-interface', function () {
    return Inertia::render('UserInterface');
})->middleware(['auth', 'verified'])->name('user-interface');

Route::get('/librarian-interface', function () {
    return Inertia::render('LibrarianInterface');
})->middleware(['auth', 'verified'])->name('librarian-interface');

Route::get('/admin-interface', function () {
    return Inertia::render('AdminInterface');
})->middleware(['auth', 'verified'])->name('admin-interface');



Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';
