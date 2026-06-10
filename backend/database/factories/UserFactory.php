<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'company_id'         => 1,
            'name'               => fake()->name(),
            'email'              => fake()->unique()->safeEmail(),
            'email_verified_at'  => now(),
            'password'           => static::$password ??= Hash::make('password'),
            'role'               => 'company_admin',
            'remember_token'     => Str::random(10),
        ];
    }

    public function admin(): static
    {
        return $this->state(['role' => 'company_admin']);
    }

    public function employee(): static
    {
        return $this->state(['role' => 'employee']);
    }

    public function unverified(): static
    {
        return $this->state(['email_verified_at' => null]);
    }
}
