<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function getBalance(Request $request){

        $user = Auth::user();

        return response() -> json([
            'message' => 'Balance retrieved succesfully',
            'balance' => $user -> balance
        ]);

    }

    public function deposit(Request $request){

        $request -> validate([
            'amount' => 'required|numeric|min:0.01',
        ]);

        $user = Auth::user();
        $amount = (float) $request -> amount;

        DB::transaction(function() use ($user, $amount){
            $user -> refresh();
            $user -> balance += $amount;
            $user -> save();

            Transaction::create([
                'user_id' => $user -> id,
                'type' => 'deposit',
                'amount' => $amount,
                'description' => 'Added funds',
                'related_user_id' => null,
            ]);
        });

        return response() -> json([
            'message' => 'Funds deposited successfully',
            'new_balance' => Auth::user() -> balance
        ]);

    }

    public function transfer(Request $request){
        $request -> validate([
            'recipient_email' => 'required|string|email|exists:users,email',
            'amount' => 'required|numeric|min:0.01'
        ]);

        $sender = Auth::user();
        $recipient = User::where('email', $request -> recipient_email) -> first();
        $amount = (float) $request -> amount;

        if($sender -> id === $recipient -> id){
            throw ValidationException::withMessages([
                'recipient_email' => ['Canot transfer to self']
            ]);
        }

        DB::transaction(function () use ($sender, $recipient, $amount){
            $sender -> refresh();
            $recipient -> refresh();

            if($sender -> balance < $amount){
                throw ValidationException::withMessages([
                    'amount' => ['Insufficient funds']
                ]);
            }

            $sender -> balance -= $amount;
            $sender -> save();
            $recipient -> balance += $amount;
            $recipient -> save();

            Transaction::create([
                'user_id' => $sender->id,
                'type' => 'debit',
                'amount' => $amount,
                'description' => 'Funds sent to ' . $recipient -> name . ' (' . $recipient -> email . ')',
                'related_user_id' => $recipient -> id
            ]);

            Transaction::create([
                'user_id' => $recipient->id,
                'type' => 'credit',
                'amount' => $amount,
                'description' => 'Funds received from ' . $sender->name . ' (' . $sender->email . ')',
                'related_user_id' => $sender->id,
            ]);
        });

        return response() -> json ([
            'message' => 'Funds transferred successfully',
            'new_balance' => Auth::user() -> balance
        ]);

    }

    public function getTransactions(Request $request) {
        $user = $request -> user();
        if (!$user) {
            return response() -> json(['message' => 'Unauthourised'], 401);
        }

        $transactions = Transaction::where( 'user_id', $user->id) -> orderByDesc('created_at') -> get();

        $formattedTransactions = $transactions -> map (function($transaction) use ($user){
            $description = $transaction -> description;
            $relatedUser = null;

            if (in_array($transaction -> type, ['debit', 'credit'])){
                if($transaction -> related_user_id){
                    $relatedUser = User::find($transaction->related_user_id);
                }

            }

            return [ 
                'id' => $transaction->id,
                'type' => str_replace('_', ' ', $transaction->type), 
                'amount' => $transaction->amount,
                'description' => $description,
                'day' => $transaction->created_at->format('Y/m/d'),
                'time' =>  $transaction->created_at->format('H:i:s'),
                'status' => $transaction->status,
                'user_id' => $transaction->user_id, 
                'related_user_id' => $transaction->related_user_id, 
            ];
        });

        return response() -> json (['transactions' => $formattedTransactions]);

    }
}
    

