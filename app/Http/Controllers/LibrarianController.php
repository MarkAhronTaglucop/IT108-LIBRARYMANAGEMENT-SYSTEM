<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class LibrarianController extends Controller
{
    public function display_info()
    {
        $users = User::with('role')->get();
        $roles = DB::table('roles')->get();
        $books = DB::select('SELECT * FROM view_books');

        return Inertia::render('LibrarianInterface', [
            'users' => $users,
            'roles' => $roles,
            'books' => $books
        ]);
    }
}
