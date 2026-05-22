from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
from models.ensemble import LateFusionEnsemble

router = APIRouter()
ensemble_model = LateFusionEnsemble()

class SessionPayload(BaseModel):
    session_id: str
    patient_uuid: str
    clinical_results: Dict[str, Any]
    visuospatial_results: Dict[str, Any]
    acoustic_results: Dict[str, Any]

@router.post("/analyze_session")
def analyze_session(payload: SessionPayload):
    """
    Receives a completed session's data containing all three modalities.
    Fuses the features and returns a cognitive risk probability score.
    """
    try:
        # Convert Pydantic model to dict
        data = payload.dict()
        
        # Execute ensemble prediction
        risk_evaluation = ensemble_model.predict_risk(data)
        
        # In a full deployment, this result would be written back to Supabase here
        # supabase.table('sessions').update({'risk_score': risk_evaluation}).eq('id', payload.session_id).execute()

        return {
            "status": "success",
            "session_id": payload.session_id,
            "analysis": risk_evaluation
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
