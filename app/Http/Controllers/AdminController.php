<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class AdminController extends Controller
{
    public function dashboard()
    {
        $users = DB::select('SELECT * FROM users_view');
        return Inertia::render('AdminInterface', ['current_user' => $users]);
    }
}
