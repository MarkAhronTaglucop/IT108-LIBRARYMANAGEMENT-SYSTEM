<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class UserController extends Controller
{

    public function display_info()
    {
        $users = User::with('role')->get();
        $roles = DB::table('roles')->get();
        $books = DB::select('SELECT * FROM view_books');

        return Inertia::render('UserInterface', [
            'users' => $users,
            'roles' => $roles,
            'books' => $books
        ]);
    }

    public function search(Request $request)
    {
        $searchQuery = $request->input('searchQuery', '');

        if (empty($searchQuery)) {
            return Inertia::render('UserInterface', [
                'searchedbooks' => []
            ]);
        }

        try {
            $searchedbooks = DB::select('SELECT * FROM SearchBooksByTitle(?)', [$searchQuery]);
        } catch (\Exception $e) {
            return Inertia::render('UserInterface', [
                'searchedbooks' => [],
                'error' => $e->getMessage() // Optional: Include error for debugging
            ]);
        }

        return Inertia::render('UserInterface', [
            'searchedbooks' => $searchedbooks
        ]);
    }
}
