import os

import numpy as np
from scipy.io import wavfile

from visqol import visqol_lib_py
from visqol.pb2 import visqol_config_pb2
from visqol.pb2 import similarity_result_pb2

config = visqol_config_pb2.VisqolConfig()

mode = "speech"
if mode == "audio":
    config.audio.sample_rate = 48000
    config.options.use_speech_scoring = False
    svr_model_path = "libsvm_nu_svr_model.txt"
elif mode == "speech":
    config.audio.sample_rate = 16000
    config.options.use_speech_scoring = True
    svr_model_path = "lattice_tcditugenmeetpackhref_ls2_nl60_lr12_bs2048_learn.005_ep2400_train1_7_raw.tflite"
else:
    raise ValueError(f"Unrecognized mode: {mode}")

config.options.svr_model_path = os.path.join(
    os.path.dirname(visqol_lib_py.__file__), "model", svr_model_path)

api = visqol_lib_py.VisqolApi()
api.Create(config)

# Both files have actually a sample rate of fs=8000Hz
# So normally we would have to resample to 16000Hz 
# (based on the official documentation)
# 
# ---------------------------------------------------------
# [1] mos-result w.out 'manual' resampling (enc-dec):
# moslqo: 4.683368925457326
#
reference: str = "caller.wav"
degraded: str = "callee.wav"

# Option 1:
_, ref_file_scipy = wavfile.read(reference)
_, deg_file_scipy = wavfile.read(degraded)
print(f"Type of reg_file_scipy: {ref_file_scipy.dtype}")
print(f"Type of deg_file_scipy: {deg_file_scipy.dtype}")
print(np.iinfo(np.int16).max, np.iinfo(np.int16).min)

similarity_result_scipy = api.Measure(
    ref_file_scipy.astype(dtype=np.float64, copy=False), 
    deg_file_scipy.astype(dtype=np.float64, copy=False)
)

# Test results
print(f"MOS w. scipy: {similarity_result_scipy.moslqo:_>10}")
