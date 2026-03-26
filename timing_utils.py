# timing_utils.py  
import time  
from hyperon import *  
from hyperon.ext import register_atoms  
from hyperon.atoms import OperationAtom  # ← Add this import  
  
@register_atoms(pass_metta=True)  
def timing_utils(metta: MeTTa):  
    def get_current_time():  
        return time.time()  
      
    time_atom = OperationAtom('python-time',   
                             lambda: get_current_time(),  
                             ['Expression'], unwrap=False)  
      
    return {"python-time": time_atom}
