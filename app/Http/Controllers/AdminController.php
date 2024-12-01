<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class AdminController extends Controller
{

    public function users()
    {
        $users = User::with('role')->get();
        $roles = DB::table('roles')->get();
        return Inertia::render('AdminInterface', ['users' => $users, 'roles' => $roles]);
    }

    public function updateUserRole(Request $request, User $user)
    {

        // $before = DB::select("select current_user, session_user");
        // Prevent editing of admin roles
        if ($user->role_id == 3) {
            return back()->withErrors(['message' => 'Admin roles cannot be edited or demoted.']);
        }

        $validated = $request->validate([
            'role_id' => 'required|exists:roles,id', // Ensure the role_id exists in the roles table
        ]);

        // Prevent demotion if the new role is admin
        if ($validated['role_id'] != 3 && $user->role_id == 3) {
            return back()->withErrors(['message' => 'Admins cannot be demoted.']);
        }

        $user->update(['role_id' => $validated['role_id']]);

        // $after = DB::select("select current_user, session_user");

        // dd($before, $after);

        return back()->with('message', 'User role updated successfully!');
    }


    public function deleteUser(User $user)
    {
        if ($user->role->user_type === 'admin') {
            return redirect()->back()->with('error', 'Admin users cannot be deleted.');
        }
        $user->delete();

        return redirect()->back()->with('message', 'User deleted successfully');
    }
}
