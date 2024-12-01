<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class LibrarianController extends Controller
{
    public function users()
    {
        $users = User::with('role')->get();
        $roles = DB::table('roles')->get();
        return Inertia::render('LibrarianInterface', ['users' => $users, 'roles' => $roles]);
    }
}
