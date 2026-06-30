<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Support\Facades\URL;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

  

    public function saveImage($image, $path = 'profiles')
   {
    if (!$image) {
        return null;
    }

    // Flutter multipart file gönderiyorsa
    if ($image instanceof \Illuminate\Http\UploadedFile) {
        $storedPath = $image->store($path, 'public');

        return URL::to('/') . '/storage/' . $storedPath;
    }

    // Eski base64 destek kalsın
    $filename = time() . '.png';

    \Storage::disk('public')->put(
        $path . '/' . $filename,
        base64_decode($image)
    );

    return URL::to('/') . '/storage/' . $path . '/' . $filename;
    } 
}