"""
Model Monitoring & Health Check Dashboard
Monitor model performance dan data freshness
"""

import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
import numpy as np

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class GGRMModelMonitor:
    """Monitor untuk GGRM stock prediction model"""
    
    def __init__(self):
        self.model_file = Path("stock_model.keras")
        self.scaler_file = Path("scaler_ggrm.pkl")
        self.metadata_file = Path("model_metadata.json")
        self.test_results_file = Path("test_results.json")
        self.predictions_file = Path("ggrm_predictions_history.json")
    
    def check_files_exist(self):
        """Check jika semua files ada"""
        files = {
            "Model": self.model_file,
            "Scaler": self.scaler_file,
            "Metadata": self.metadata_file,
        }
        
        print("\n📁 FILE CHECK")
        print("-" * 60)
        
        all_exist = True
        for name, file in files.items():
            exists = file.exists()
            status = "✅" if exists else "❌"
            size = f"({file.stat().st_size / 1024 / 1024:.2f} MB)" if exists else ""
            print(f"{status} {name}: {file} {size}")
            if not exists:
                all_exist = False
        
        return all_exist
    
    def check_model_freshness(self):
        """Check model age"""
        print("\n🕐 MODEL FRESHNESS")
        print("-" * 60)
        
        if not self.metadata_file.exists():
            print("❌ Metadata file tidak ada")
            return False
        
        with open(self.metadata_file, 'r') as f:
            metadata = json.load(f)
        
        trained_date = datetime.fromisoformat(metadata['trained_date'])
        age_days = (datetime.now() - trained_date).days
        
        if age_days > 30:
            status = "⚠️ OLD"
            recommendation = "Retrain segera dengan python retrain_ggrm.py"
        elif age_days > 7:
            status = "⚡ OKAY"
            recommendation = "Retrain dalam 1 minggu"
        else:
            status = "✅ FRESH"
            recommendation = "Model masih baru"
        
        print(f"{status} Model age: {age_days} hari")
        print(f"📅 Trained: {trained_date.strftime('%Y-%m-%d %H:%M')}")
        print(f"💡 {recommendation}")
        
        return age_days <= 30
    
    def check_test_results(self):
        """Check last test results"""
        print("\n📊 LAST TEST RESULTS")
        print("-" * 60)
        
        if not self.test_results_file.exists():
            print("❌ Test results file tidak ada")
            print("💡 Run: python validate_ggrm_model.py")
            return False
        
        with open(self.test_results_file, 'r') as f:
            results = json.load(f)
        
        metrics = results.get('test_metrics', {})
        
        mape = metrics.get('mape', None)
        r2 = metrics.get('r2', None)
        mae = metrics.get('mae', None)
        
        if mape is not None:
            mape_status = "✅" if mape < 5 else "⚠️" if mape < 10 else "❌"
            print(f"{mape_status} MAPE: {mape:.2f}% {'(Good)' if mape < 5 else '(Fair)' if mape < 10 else '(Poor)'}")
        
        if r2 is not None:
            r2_status = "✅" if r2 > 0.7 else "⚠️" if r2 > 0.5 else "❌"
            print(f"{r2_status} R²: {r2:.4f} {'(Good)' if r2 > 0.7 else '(Fair)' if r2 > 0.5 else '(Poor)'}")
        
        if mae is not None:
            print(f"📈 MAE: Rp {mae:,.0f}")
        
        return True
    
    def check_prediction_accuracy(self):
        """Check accuracy dari predictions"""
        print("\n🎯 PREDICTION ACCURACY")
        print("-" * 60)
        
        if not self.predictions_file.exists():
            print("ℹ️ Predictions history belum ada")
            print("💡 Run: python daily_prediction.py")
            return None
        
        with open(self.predictions_file, 'r') as f:
            history = json.load(f)
        
        predictions = history.get('predictions', [])
        
        if not predictions:
            print("ℹ️ No predictions yet")
            return None
        
        # Find completed predictions
        completed = [p for p in predictions if 'actual_price' in p]
        
        if not completed:
            print("ℹ️ Predictions pending actual prices...")
            return None
        
        # Calculate accuracy
        direction_correct = sum([p.get('direction_accuracy', False) for p in completed])
        direction_accuracy = (direction_correct / len(completed)) * 100
        
        # MAPE
        mape_values = []
        for p in completed:
            mape = abs((p.get('actual_price', p['predicted_price']) - p['predicted_price']) / p['predicted_price']) * 100
            mape_values.append(mape)
        
        avg_mape = np.mean(mape_values)
        
        accuracy_status = "✅" if direction_accuracy > 55 else "⚠️" if direction_accuracy > 50 else "❌"
        mape_status = "✅" if avg_mape < 5 else "⚠️" if avg_mape < 10 else "❌"
        
        print(f"{accuracy_status} Direction Accuracy: {direction_accuracy:.2f}%")
        print(f"{mape_status} Avg MAPE: {avg_mape:.2f}%")
        print(f"📈 Predictions evaluated: {len(completed)}/{len(predictions)}")
        
        # Last 5 predictions
        print("\n📋 Last 5 Predictions:")
        for p in completed[-5:]:
            date = p['date']
            direction = "↑" if p['direction'] == 'UP' else "↓"
            actual_direction = "↑" if p['actual_direction'] == 'UP' else "↓"
            match = "✅" if p['direction_accuracy'] else "❌"
            print(f"  {date}: {direction} → {actual_direction} {match}")
        
        return {
            'direction_accuracy': direction_accuracy,
            'avg_mape': avg_mape,
            'predictions_evaluated': len(completed)
        }
    
    def generate_health_score(self):
        """Generate overall health score"""
        print("\n" + "=" * 60)
        print("🏥 OVERALL HEALTH SCORE")
        print("=" * 60)
        
        scores = []
        
        # File check (25 points)
        if self.check_files_exist():
            scores.append(25)
        else:
            scores.append(0)
        
        # Freshness (25 points)
        if self.check_model_freshness():
            scores.append(25)
        else:
            scores.append(12)
        
        # Test results (25 points)
        if self.check_test_results():
            scores.append(25)
        else:
            scores.append(10)
        
        # Predictions (25 points)
        acc = self.check_prediction_accuracy()
        if acc and acc['direction_accuracy'] > 55:
            scores.append(25)
        elif acc and acc['direction_accuracy'] > 50:
            scores.append(15)
        else:
            scores.append(10)
        
        total_score = sum(scores)
        percentage = (total_score / 100) * 100
        
        if percentage >= 80:
            status = "🟢 HEALTHY"
            color = "GREEN"
        elif percentage >= 60:
            status = "🟡 FAIR"
            color = "YELLOW"
        else:
            status = "🔴 NEEDS ATTENTION"
            color = "RED"
        
        print(f"\n{status}")
        print(f"Score: {total_score}/100 ({percentage:.0f}%)")
        
        if percentage < 80:
            print("\n⚠️ RECOMMENDATIONS:")
            if percentage < 60:
                print("  1. Check file integrity (model, scaler, metadata)")
                print("  2. Retrain model with latest data")
                print("  3. Validate model performance")
                print("  4. Review error logs")
            else:
                print("  1. Consider retraining model")
                print("  2. Update test results")
                print("  3. Monitor prediction accuracy")
        
        print("=" * 60)
        
        return {
            'status': status,
            'score': total_score,
            'percentage': percentage,
            'color': color
        }
    
    def full_report(self):
        """Generate complete health report"""
        print("\n" + "=" * 60)
        print("GGRM STOCK PREDICTION MODEL - MONITORING REPORT")
        print("=" * 60)
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        self.check_files_exist()
        self.check_model_freshness()
        self.check_test_results()
        self.check_prediction_accuracy()
        health = self.generate_health_score()
        
        return health

def main():
    monitor = GGRMModelMonitor()
    health = monitor.full_report()
    
    # Return exit code based on health
    if health['percentage'] >= 80:
        return 0
    elif health['percentage'] >= 60:
        return 1
    else:
        return 2

if __name__ == "__main__":
    import sys
    sys.exit(main())
