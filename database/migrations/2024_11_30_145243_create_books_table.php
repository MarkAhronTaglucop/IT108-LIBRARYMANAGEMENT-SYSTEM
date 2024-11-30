<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('books', function (Blueprint $table) {
            $table->id('book_id'); // Custom primary key
            $table->string('title', 255);
            $table->string('category', 50);
            $table->string('genre', 50);
            $table->date('year_published');
            $table->foreignId('author_id')
                  ->constrained('authors', 'author_id') // Reference the correct column
                  ->onDelete('cascade'); // Handle cascading deletes
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('books');
    }
};
